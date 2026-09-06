<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Business Dashboard | CarVerse</title>
  <link rel="stylesheet" href="assets/css/carverse.css">
  <style>
    /* ── Dashboard layout ──────────────────────────────────────────────── */
    .dash-page   { padding: 52px 0 80px; }
    .dash-hero   {
      background: var(--deep);
      color: #fff;
      padding: 52px 0 48px;
      margin-bottom: 0;
    }
    .dash-hero .eyebrow { margin-bottom: 10px; }
    .dash-hero h1       { font-size: 38px; letter-spacing: -1.5px; margin: 0 0 8px; }
    .dash-hero h1 span  { color: var(--green); }
    .dash-hero p        { color: #aec5b5; margin: 0; font-size: 15px; }

    /* ── Stats row ─────────────────────────────────────────────────────── */
    .stats-bar {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 16px;
      margin: 32px 0;
    }
    .stat-card {
      background: #fff;
      border: 1px solid var(--line);
      border-radius: 13px;
      padding: 22px 20px;
    }
    .stat-card .stat-label {
      font-size: 11px;
      font-weight: 900;
      letter-spacing: 1px;
      text-transform: uppercase;
      color: var(--muted);
      margin-bottom: 8px;
    }
    .stat-card .stat-value {
      font-size: 32px;
      font-weight: 900;
      letter-spacing: -1.5px;
      color: var(--ink);
    }
    .stat-card .stat-note {
      font-size: 12px;
      color: var(--muted);
      margin-top: 4px;
    }

    /* ── Action cards grid ─────────────────────────────────────────────── */
    .action-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 18px;
      margin-top: 8px;
    }
    .action-card {
      background: #fff;
      border: 1px solid var(--line);
      border-radius: 13px;
      padding: 28px 24px;
      display: flex;
      flex-direction: column;
      gap: 10px;
      transition: .2s;
    }
    .action-card:hover {
      transform: translateY(-3px);
      box-shadow: var(--shadow);
    }
    .action-card .ac-icon {
      font-size: 28px;
      line-height: 1;
    }
    .action-card h3 {
      font-size: 18px;
      margin: 0;
      letter-spacing: -.5px;
    }
    .action-card p {
      font-size: 13px;
      color: var(--muted);
      margin: 0;
      line-height: 1.55;
      flex: 1;
    }
    .action-card .coming-soon {
      font-size: 11px;
      font-weight: 900;
      letter-spacing: .8px;
      text-transform: uppercase;
      color: #b0beb5;
      background: #f4f7f4;
      border-radius: 99px;
      padding: 4px 10px;
      display: inline-block;
      width: fit-content;
    }

    /* ── Account info panel ────────────────────────────────────────────── */
    .account-panel {
      background: linear-gradient(135deg, #eaf6df, #f9fcf5);
      border-radius: 14px;
      padding: 28px 32px;
      margin-top: 32px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 24px;
    }
    .account-panel h2  { font-size: 20px; margin: 0 0 6px; }
    .account-panel p   { font-size: 13px; color: var(--muted); margin: 0; }
    .account-panel .actions { display: flex; gap: 10px; flex-shrink: 0; }

    @media (max-width: 800px) {
      .stats-bar, .action-grid { grid-template-columns: 1fr 1fr; }
      .account-panel { flex-direction: column; align-items: flex-start; }
    }
    @media (max-width: 540px) {
      .stats-bar, .action-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>

<%
  // ── Auth guard: only BUSINESS_PARTNER sessions may access this page ──
  String businessId   = (String) session.getAttribute("BUSINESS_ID");
  String businessName = (String) session.getAttribute("BUSINESS_NAME");
  String brandName    = (String) session.getAttribute("BRAND_NAME");
  String role         = (String) session.getAttribute("USER_ROLE");

  if (businessId == null || !"BUSINESS_PARTNER".equals(role)) {
    response.sendRedirect("business-login.jsp");
    return;
  }
  if (businessName == null) businessName = "Business Partner";
  if (brandName    == null) brandName    = "";

  // ── Live dashboard stats ─────────────────────────────────────────────────
  int    dashActiveCars     = 0;
  int    dashTotalBookings  = 0;
  double dashMonthlyRevenue = 0;
  double dashCommission     = 0;
  int    dashPendingCancels = 0;
  try {
    com.servlet.BusinessDAO _dao = new com.servlet.BusinessDAO();
    dashActiveCars     = _dao.getActiveCarCount(businessId);
    dashTotalBookings  = _dao.getTotalBookingCount(businessId);
    dashMonthlyRevenue = _dao.getMonthlyRevenue(businessId);
    dashPendingCancels = _dao.getPendingCancellationCount(businessId);
    double _rate       = _dao.getCommissionRate(businessId);
    dashCommission     = dashMonthlyRevenue * (_rate / 100.0);
  } catch (Exception _e) { /* stats unavailable — show zeroes */ }
%>

<!-- ── Navbar ──────────────────────────────────────────────────────────── -->
<nav class="nav">
  <div class="shell">
    <a class="brand" href="index.jsp">CARVERSE</a>

    <div class="navlinks">
      <a href="index.jsp">Explore</a>
      <a href="car-search.jsp">New Cars</a>
      <a href="compare.jsp">Compare</a>
      <a class="active" href="business-dashboard.jsp">Dashboard</a>
    </div>

    <span class="user-name" style="cursor:default;">
      <%= businessName %>
    </span>

    <!-- Logout as a POST form (safer than a plain GET link) -->
    <form action="BusinessLogout" method="post" style="margin:0;">
      <button class="btn btn-outline" type="submit">Sign out</button>
    </form>
  </div>
</nav>

<!-- ── Hero strip ───────────────────────────────────────────────────────── -->
<div class="dash-hero">
  <div class="shell">
    <div class="eyebrow">Business Partner Dashboard</div>
    <h1>Welcome back, <span><%= businessName %></span></h1>
    <p>
      <% if (!brandName.isEmpty()) { %><strong style="color:#fff;"><%= brandName %></strong> &nbsp;·&nbsp;<% } %>
      Partner ID: <%= businessId %>
    </p>
  </div>
</div>

<!-- ── Main content ─────────────────────────────────────────────────────── -->
<div class="dash-page">
  <div class="shell">

    <!-- Stats bar -->
    <div class="stats-bar">
      <div class="stat-card">
        <div class="stat-label">Active Listings</div>
        <div class="stat-value"><%= dashActiveCars %></div>
        <div class="stat-note">Available cars</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Total Bookings</div>
        <div class="stat-value"><%= dashTotalBookings %></div>
        <div class="stat-note">All time</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">This Month's Revenue</div>
        <div class="stat-value">₹<%= String.format("%,.0f", dashMonthlyRevenue) %></div>
        <div class="stat-note">Gross booking amount</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Commission Earned</div>
        <div class="stat-value">₹<%= String.format("%,.0f", dashCommission) %></div>
        <div class="stat-note">Platform's share this month</div>
      </div>
    </div>
    <% if (dashPendingCancels > 0) { %>
    <div style="background:#fffbeb;border:1px solid #fcd34d;border-radius:10px;padding:12px 18px;margin-bottom:18px;font-size:14px;font-weight:600;color:#92400e;">
      ⚠️ You have <strong><%= dashPendingCancels %></strong> pending cancellation request<%= dashPendingCancels > 1 ? "s" : "" %>.
      <a href="BusinessBookings" style="color:#92400e;text-decoration:underline;">Review now →</a>
    </div>
    <% } %>

    <!-- Section heading -->
    <div class="section-head" style="margin-bottom:18px;">
      <div>
        <div class="eyebrow">What would you like to do?</div>
        <h2 style="margin-top:6px;">Manage your business</h2>
      </div>
    </div>

    <!-- Action cards -->
    <div class="action-grid">

      <a class="action-card" href="BusinessCar?action=list" style="text-decoration:none;color:inherit;">
        <div class="ac-icon">🚗</div>
        <h3>Manage Cars</h3>
        <p>Add new car listings, update availability, pricing and specifications.</p>
        <span class="btn btn-primary" style="font-size:12px;padding:8px 14px;width:fit-content;">Open →</span>
      </a>

      <a class="action-card" href="BusinessInventory" style="text-decoration:none;color:inherit;">
        <div class="ac-icon">📦</div>
        <h3>Manage Inventory</h3>
        <p>Track your fleet, monitor stock levels, and manage car allocation.</p>
        <span class="btn btn-primary" style="font-size:12px;padding:8px 14px;width:fit-content;">Open →</span>
      </a>

      <a class="action-card" href="BusinessBookings" style="text-decoration:none;color:inherit;">
        <div class="ac-icon">📋</div>
        <h3>View Bookings</h3>
        <p>See all bookings made for your cars and manage cancellation requests.</p>
        <span class="btn btn-primary" style="font-size:12px;padding:8px 14px;width:fit-content;">Open →</span>
      </a>

      <a class="action-card" href="BusinessBookings" style="text-decoration:none;color:inherit;">
        <div class="ac-icon">↩️</div>
        <h3>Cancellation Requests</h3>
        <p>Review and respond to cancellation requests from customers.</p>
        <% if (dashPendingCancels > 0) { %>
        <span style="font-size:12px;font-weight:900;color:#92400e;background:#fef9c3;border-radius:99px;padding:4px 12px;width:fit-content;">
          <%= dashPendingCancels %> pending
        </span>
        <% } else { %>
        <span class="btn btn-primary" style="font-size:12px;padding:8px 14px;width:fit-content;">Open →</span>
        <% } %>
      </a>

      <a class="action-card" href="BusinessEarnings" style="text-decoration:none;color:inherit;">
        <div class="ac-icon">💰</div>
        <h3>Commission &amp; Earnings</h3>
        <p>View commission breakdowns, payout history and earning reports.</p>
        <span class="btn btn-primary" style="font-size:12px;padding:8px 14px;width:fit-content;">Open →</span>
      </a>

      <a class="action-card" href="BusinessProfile" style="text-decoration:none;color:inherit;">
        <div class="ac-icon">🏢</div>
        <h3>Business Profile</h3>
        <p>Update your business information, contact details and branding.</p>
        <span class="btn btn-primary" style="font-size:12px;padding:8px 14px;width:fit-content;">Open →</span>
      </a>

    </div>

    <!-- Account info + logout panel -->
    <div class="account-panel">
      <div>
        <h2>Account</h2>
        <p>
          Signed in as a <strong>Business Partner</strong>.
          Partner ID: <code><%= businessId %></code>
        </p>
      </div>
      <div class="actions">
        <form action="BusinessLogout" method="post" style="margin:0;">
          <button class="btn btn-dark" type="submit">Sign out →</button>
        </form>
      </div>
    </div>

  </div><%-- .shell --%>
</div><%-- .dash-page --%>

<!-- ── Footer ───────────────────────────────────────────────────────────── -->
<footer class="footer">
  <div class="shell">
    <div>
      <a class="brand" href="index.jsp">CARVERSE</a>
      <p>Drive your next decision with confidence.</p>
    </div>
    <div>Explore · Compare · Book · Maintenance · Support</div>
    <div>© 2026 CarVerse</div>
  </div>
</footer>

<script src="assets/js/carverse.js"></script>
</body>
</html>
