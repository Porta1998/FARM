import os
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.config['SECRET_KEY'] = 'dev-secret-key'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///farm.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    profile = db.relationship('UserProfile', backref='user', uselist=False)
    transactions = db.relationship('Transaction', backref='user', lazy=True)
    recurring_transactions = db.relationship('RecurringTransaction', backref='user', lazy=True)

class UserProfile(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    initial_balance = db.Column(db.Float, default=0.0)
    goal_name = db.Column(db.String(100))
    goal_target = db.Column(db.Float, default=0.0)

class Transaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    category = db.Column(db.String(50))
    type = db.Column(db.String(10))  # 'income' or 'expense'
    date = db.Column(db.DateTime, default=datetime.utcnow)
    description = db.Column(db.String(200))

class RecurringTransaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    category = db.Column(db.String(50))
    type = db.Column(db.String(10))  # 'income' or 'expense'
    frequency = db.Column(db.String(20))  # 'monthly', 'weekly'
    day_of_month = db.Column(db.Integer)
    description = db.Column(db.String(200))

@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))

with app.app_context():
    db.create_all()

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user = User.query.filter_by(username=username).first()
        if user and check_password_hash(user.password_hash, password):
            login_user(user)
            if not user.profile or user.profile.initial_balance == 0:
                return redirect(url_for('setup_saldo'))
            return redirect(url_for('dashboard'))
        flash('Invalid username or password')
    return render_template('onboarding.html')

@app.route('/register', methods=['POST'])
def register():
    username = request.form.get('username')
    password = request.form.get('password')
    if User.query.filter_by(username=username).first():
        flash('Username già esistente')
        return redirect(url_for('login'))

    user = User(username=username, password_hash=generate_password_hash(password))
    db.session.add(user)
    db.session.commit()

    profile = UserProfile(user_id=user.id, goal_name='Nuova Serra', goal_target=25000.0)
    db.session.add(profile)
    db.session.commit()

    login_user(user)
    return redirect(url_for('setup_saldo'))

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/')
@login_required
def dashboard():
    # Calculate balance
    initial = current_user.profile.initial_balance
    txs = Transaction.query.filter_by(user_id=current_user.id).all()
    tx_balance = sum(t.amount if t.type == 'income' else -t.amount for t in txs)
    current_balance = initial + tx_balance

    # Projections
    recurring = RecurringTransaction.query.filter_by(user_id=current_user.id).all()
    monthly_net = sum(r.amount if r.type == 'income' else -r.amount for r in recurring)
    projection_12m = current_balance + (monthly_net * 12)

    # Recent transactions
    recent_txs = Transaction.query.filter_by(user_id=current_user.id).order_by(Transaction.date.desc()).limit(5).all()

    # Upcoming payments (simplified)
    upcoming = [r for r in recurring if r.type == 'expense']

    return render_template('dashboard_home.html',
                           balance=current_balance,
                           projection_12m=projection_12m,
                           recent_txs=recent_txs,
                           upcoming=upcoming,
                           monthly_net=monthly_net)

@app.route('/insert', methods=['GET', 'POST'])
@login_required
def insert():
    if request.method == 'POST':
        amount = float(request.form.get('amount', 0))
        category = request.form.get('category', 'Altro')
        type = request.form.get('type', 'expense')
        description = request.form.get('description', '')

        tx = Transaction(user_id=current_user.id, amount=amount, category=category, type=type, description=description)
        db.session.add(tx)
        db.session.commit()
        return redirect(url_for('feedback_impatto', tx_id=tx.id))

    return render_template('inserimento_rapido.html')

@app.route('/feedback-impatto/<int:tx_id>')
@login_required
def feedback_impatto(tx_id):
    tx = db.session.get(Transaction, tx_id)
    if not tx:
        return "Transaction not found", 404
    # Simple impact calculation: how much this single expense would be in a year
    annual_impact = tx.amount * 12 if tx.type == 'expense' else 0
    return render_template('feedback_impatto.html', tx=tx, annual_impact=annual_impact)

@app.route('/simulatore')
@login_required
def simulatore():
    recurring = RecurringTransaction.query.filter_by(user_id=current_user.id).all()
    return render_template('simulatore_abitudini.html', recurring=recurring)

@app.route('/confronto')
@login_required
def confronto():
    # Fetch data for comparison
    initial = current_user.profile.initial_balance
    txs = Transaction.query.filter_by(user_id=current_user.id).all()
    tx_balance = sum(t.amount if t.type == 'income' else -t.amount for t in txs)
    current_balance = initial + tx_balance

    recurring = RecurringTransaction.query.filter_by(user_id=current_user.id).all()
    monthly_net = sum(r.amount if r.type == 'income' else -r.amount for r in recurring)

    projection_12m = current_balance + (monthly_net * 12)

    # Optimized projection (simulation)
    # Assume 10% reduction in expenses as optimization
    monthly_expense = sum(r.amount for r in recurring if r.type == 'expense')
    optimized_monthly_net = monthly_net + (monthly_expense * 0.1)
    optimized_projection_12m = current_balance + (optimized_monthly_net * 12)

    gain_extra = optimized_projection_12m - projection_12m

    return render_template('confronto_proiezioni.html',
                           current_balance=current_balance,
                           projection_12m=projection_12m,
                           optimized_projection_12m=optimized_projection_12m,
                           gain_extra=gain_extra)

@app.route('/api/chart-data')
@login_required
def chart_data():
    initial = current_user.profile.initial_balance
    txs = Transaction.query.filter_by(user_id=current_user.id).all()
    tx_balance = sum(t.amount if t.type == 'income' else -t.amount for t in txs)
    current_balance = initial + tx_balance

    recurring = RecurringTransaction.query.filter_by(user_id=current_user.id).all()
    monthly_net = sum(r.amount if r.type == 'income' else -r.amount for r in recurring)

    # Generate labels and data for 12 months
    labels = []
    projection_data = []
    optimized_data = []

    monthly_expense = sum(r.amount for r in recurring if r.type == 'expense')
    optimized_monthly_net = monthly_net + (monthly_expense * 0.1)

    for i in range(13):
        labels.append(f"Mese {i}")
        projection_data.append(current_balance + (monthly_net * i))
        optimized_data.append(current_balance + (optimized_monthly_net * i))

    return jsonify({
        'labels': labels,
        'projection': projection_data,
        'optimized': optimized_data
    })

@app.route('/setup-saldo', methods=['GET', 'POST'])
@login_required
def setup_saldo():
    if request.method == 'POST':
        balance = float(request.form.get('balance', 0))
        current_user.profile.initial_balance = balance
        db.session.commit()
        return redirect(url_for('config_entrate'))
    return render_template('setup_saldo.html')

@app.route('/config-entrate', methods=['GET', 'POST'])
@login_required
def config_entrate():
    if request.method == 'POST':
        # Logic to save recurring incomes
        RecurringTransaction.query.filter_by(user_id=current_user.id, type='income').delete()
        for category, amount in request.form.items():
            amount_val = float(amount or 0)
            if amount_val > 0:
                rt = RecurringTransaction(
                    user_id=current_user.id,
                    amount=amount_val,
                    category=category,
                    type='income',
                    frequency='monthly'
                )
                db.session.add(rt)
        db.session.commit()
        return redirect(url_for('config_uscite'))
    return render_template('config_entrate.html')

@app.route('/config-uscite', methods=['GET', 'POST'])
@login_required
def config_uscite():
    if request.method == 'POST':
        # Logic to save recurring expenses
        RecurringTransaction.query.filter_by(user_id=current_user.id, type='expense').delete()
        for category, amount in request.form.items():
            amount_val = float(amount or 0)
            if amount_val > 0:
                rt = RecurringTransaction(
                    user_id=current_user.id,
                    amount=amount_val,
                    category=category,
                    type='expense',
                    frequency='monthly'
                )
                db.session.add(rt)
        db.session.commit()
        return redirect(url_for('riepilogo'))
    return render_template('config_uscite.html')

@app.route('/riepilogo')
@login_required
def riepilogo():
    items = RecurringTransaction.query.filter_by(user_id=current_user.id).all()
    total_income = sum(i.amount for i in items if i.type == 'income')
    total_expense = sum(i.amount for i in items if i.type == 'expense')
    return render_template('riepilogo_ricorrenti.html', items=items, total_income=total_income, total_expense=total_expense)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
