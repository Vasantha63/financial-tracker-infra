// app.js — All logic here

// Sample data
let transactions = [
  { id: 1, desc: 'Monthly Salary',    amount: 50000, type: 'income',  cat: 'Salary' },
  { id: 2, desc: 'House Rent',        amount: 12000, type: 'expense', cat: 'Rent' },
  { id: 3, desc: 'Groceries',         amount: 3500,  type: 'expense', cat: 'Food' },
  { id: 4, desc: 'Freelance Project', amount: 15000, type: 'income',  cat: 'Other' },
];

let nextId = 5;

// Category colors
const CAT_COLORS = {
  Salary:        '#22c55e',
  Food:          '#f97316',
  Rent:          '#ef4444',
  Transport:     '#a855f7',
  Shopping:      '#ec4899',
  Entertainment: '#06b6d4',
  Health:        '#14b8a6',
  Other:         '#64748b',
};

// Format number to Indian currency
function fmt(n) {
  return '₹' + Number(n).toLocaleString('en-IN');
}

// Add new transaction
function addTransaction() {
  const desc   = document.getElementById('desc').value.trim();
  const amount = parseFloat(document.getElementById('amount').value);
  const type   = document.getElementById('type').value;
  const cat    = document.getElementById('category').value;

  if (!desc || !amount || amount <= 0) {
    alert('Please fill all fields with valid values!');
    return;
  }

  transactions.unshift({ id: nextId++, desc, amount, type, cat });

  // Clear form
  document.getElementById('desc').value   = '';
  document.getElementById('amount').value = '';

  render();
}

// Main render function
function render() {
  renderSummary();
  renderTransactions();
  renderChart();
}

function renderSummary() {
  const income  = transactions
    .filter(t => t.type === 'income')
    .reduce((sum, t) => sum + t.amount, 0);

  const expense = transactions
    .filter(t => t.type === 'expense')
    .reduce((sum, t) => sum + t.amount, 0);

  const balance = income - expense;

  document.getElementById('totalIncome').textContent  = fmt(income);
  document.getElementById('totalExpense').textContent = fmt(expense);

  const balEl = document.getElementById('netBalance');
  balEl.textContent  = fmt(balance);
  balEl.style.color  = balance >= 0 ? '#22c55e' : '#ef4444';
}

function renderTransactions() {
  const container = document.getElementById('txList');

  if (transactions.length === 0) {
    container.innerHTML = '<div class="empty-state">No transactions yet.<br/>Add one above!</div>';
    return;
  }

  container.innerHTML = transactions.slice(0, 10).map(t => `
    <div class="tx-item">
      <div class="tx-left">
        <div class="tx-icon ${t.type === 'income' ? 'inc' : 'exp'}">
          ${t.type === 'income' ? '↑' : '↓'}
        </div>
        <div>
          <div class="tx-name">${t.desc}</div>
          <div class="tx-cat">${t.cat}</div>
        </div>
      </div>
      <div class="tx-amount ${t.type === 'income' ? 'inc' : 'exp'}">
        ${t.type === 'income' ? '+' : '-'}${fmt(t.amount)}
      </div>
    </div>
  `).join('');
}

function renderChart() {
  const expenses = transactions.filter(t => t.type === 'expense');

  // Group by category
  const catTotals = {};
  expenses.forEach(t => {
    catTotals[t.cat] = (catTotals[t.cat] || 0) + t.amount;
  });

  const container = document.getElementById('barChart');

  if (Object.keys(catTotals).length === 0) {
    container.innerHTML = '<div class="empty-state">Add expenses to see breakdown</div>';
    return;
  }

  const maxVal = Math.max(...Object.values(catTotals));

  container.innerHTML = Object.entries(catTotals)
    .sort((a, b) => b[1] - a[1])
    .map(([cat, val]) => {
      const pct   = ((val / maxVal) * 100).toFixed(0);
      const color = CAT_COLORS[cat] || '#64748b';
      return `
        <div class="bar-row">
          <div class="bar-label">${cat}</div>
          <div class="bar-track">
            <div class="bar-fill" style="width:${pct}%; background:${color}">
              <span>${fmt(val)}</span>
            </div>
          </div>
        </div>
      `;
    }).join('');
}

// Enter key తో add చేయడానికి
document.getElementById('amount').addEventListener('keypress', function(e) {
  if (e.key === 'Enter') addTransaction();
});

// Initial render
render();