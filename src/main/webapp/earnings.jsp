<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, com.servlet.BusinessDAO.BookingRecord, com.servlet.BusinessDAO.EarningsSummary" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Commission & Earnings | CarVerse</title>
  <link rel="stylesheet" href="assets/css/carverse.css">
  <style>
    .bp-page { padding: 48px 0 80px; }
    .bp-hero  { background: var(--deep); color: #fff; padding: 44px 0 40px; }
    .bp-hero .eyebrow { margin-bottom: 8px; }
    .bp-hero h1 { font-size: 34px; letter-spacing: -1.5px; margin: 0 0 6px; }
    .bp-hero h1 span { color: var(--green); }
    .bp-hero p  { color: #aec5b5; margin: 0; font-size: 14px; }

    .back-link { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 700; color: var(--muted); margin-bottom: 28px; }
    .back-link:hover { color: var(--ink); }

    .alert { padding: 14px 18px; border-radius: 8px; font-size: 14px; font-weight: 600; margin-bottom: 22px; }
    .alert-error { background: #fef2f2; border: 1px solid #fca5a5; color: #b91c1c; }

    /* ── Earnings summary grid ─────────────────────────────────── */
    .earnings-grid {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;
      margin-bottom: 36px;
    }
    .earn-card {
      background: #fff; border: 1px solid var(--line);
      border-radius: 13px; padding: 22px 20px;
    }
    .earn-card .ec-label {
      font-size: 11px; font-weight: 900; letter-spacing: 1px;
      text-transform: uppercase; color: var(--muted); margin-bottom: 8px;
    }
    .earn-card .ec-value {
      font-size: 30px; font-weight: 900; letter-spacing: -1px;
      color: var(--ink);
    }
    .earn-card .ec-note {
      font-size: 12px; color: var(--muted); margin-top: 4px;
    }
    .earn-card.highlight { background: linear-gradient(135deg,#eaf6df,#f9fcf5); }
    .earn-card.highlight .ec-value { color: #3a7d0a; }

    /* ── Commission breakdown panel ────────────────────────────── */
    .commission-panel {
      background: #fff; border: 1px solid var(--line);
      border-radius: 13px; padding: 24px 26px; margin-bottom: 32px;
    }
    .commission-panel h3 { font-size: 17px; margin: 0 0 18px; letter-spacing: -.4px; }
    .comm-row {
      display: flex; justify-content: space-between; align-items: center;
      padding: 12px 0; border-bottom: 1px solid var(--line); font-size: 14px;
    }
    .comm-row:last-child  { border-bottom: none; font-weight: 900; font-size: 15px; }
    .comm-row .cr-label   { color: var(--muted); }
    .comm-row .cr-value   { font-weight: 700; }
    .comm-row.net .cr-value { color: #3a7d0a; font-size: 18px; }
    .comm-note {
      font-size: 11px; color: var(--muted); margin-top: 14px;
      padding-top: 12px; border-top: 1px dashed var(--line);
    }

    /* ── Detail table ──────────────────────────────────────────── */
    .data-table { width: 100%; border-collapse: collapse; background: #fff; border: 1px solid var(--line); border-radius: 12px; overflow: hidden; font-size: 13px; }
    .data-table th { background: #f4f7f4; padding: 12px 14px; text-align: left; font-size: 11px; font-weight: 900; text-transform: uppercase; letter-spacing: .8px; color: var(--muted); border-bottom: 1px solid var(--line); }
    .data-table td { padding: 12px 14px; border-bottom: 1px solid var(--line); vertical-align: middle; }
    .data-table tr:last-child td { border-bottom: none; }
    .data-table tr:hover td { background: #f9fcf5; }

    .badge { display: inline-block; padding: 3px 10px; border-radius: 99px; font-size: 11px; font-weight: 900; text-transform: uppercase; }
    .badge-completed { background: #dbeafe; color: #1d4ed8; }
    .badge-confirmed { background: #dcfce7; color: #15803d; }
    .badge-pending   { background: #fef9c3; color: #92400e; }
    .badge-cancelled { background: #f3f4f6; color: #6b7280; }
    .badge-na        { background: #f3f4f6; color: #9ca3af; }
    .badge-paid      { background: #dcfce7; color: #15803d; }

    .empty-state { text-align: center; padding: 56px 24px; background: #fff; border: 1px solid var(--line); border-radius: 12px; }
    .empty-state .es-icon { font-size: 44px; margin-bottom: 14px; }
    .empty-state h3 { font-size: 20px; margin: 0 0 8px; }
    .empty-state p  { color: var(--muted); font-size: 14px; }

    @media (max-width: 760px) { .earnings-grid { grid-template-columns: 1fr 1fr; } }
    @media (max-width: 480px) { .earnings-grid { grid-template-columns: 1fr; } }
  </style>
</head>
<body>
<%
  String businessId   = (String) session.getAttribute("BUSINESS_ID");
  String businessName = (String) session.getAttribute("BUSINESS_NAME");
  String role         = (String) session.getAttribute("USER_ROLE");
  if (businessId == null || !"BUSINESS_PARTNER".equals(role)) {
    response.sendRedirect("business-login.jsp"); return;
  }
  if (businessName == null) businessName = "Business Partner";

  EarningsSummary s = (EarningsSummary) request.getAttribute("summary");
  @SuppressWarnings("unchecked")
  List<BookingRecord> detail = (List<BookingRecord>) request.getAttribute("earningsDetail");

  String errorMsg = (String) request.getAttribute("error");
%>

<!-- ── Navbar ──────────────────────────────────────────────────── -->
<nav class="nav">
  <div class="shell">
    <a class="brand" href="index.jsp">CARVERSE</a>
    <div class="navlinks">
      <a href="index.jsp">Explore</a>
      <a href="car-search.jsp">New Cars</a>
      <a href="compare.jsp">Compare</a>
      <a class="active" href="business-dashboard.jsp">Dashboard</a>
    </div>
    <span class="user-name" style="cursor:default;"><%= businessName %></span>
    <form action="BusinessLogout" method="post" style="margin:0;">
      <button class="btn btn-outline" type="submit">Sign out</button>
    </form>
  </div>
</nav>

<!-- ── Hero ────────────────────────────────────────────────────── -->
<div class="bp-hero">
  <div class="shell">
    <div class="eyebrow">Business Partner · Financials</div>
    <h1>Commission &amp; <span>Earnings</span></h1>
    <p>Your booking revenue, platform commission, and net payout breakdown.</p>
  </div>
</div>

<!-- ── Main ────────────────────────────────────────────────────── -->
<div class="bp-page">
  <div class="shell">
    <a class="back-link" href="business-dashboard.jsp">← Back to Dashboard</a>

    <% if (errorMsg != null) { %>
      <div class="alert alert-error"><%= errorMsg %></div>
    <% } %>

    <% if (s != null) { %>

    <!-- ══ Summary cards ═════════════════════════════════════════ -->
    <div class="earnings-grid">
      <div class="earn-card">
        <div class="ec-label">Total Bookings</div>
        <div class="ec-value"><%= s.totalBookings %></div>
        <div class="ec-note"><%= s.completedBookings %> completed · <%= s.pendingBookings %> in progress</div>
      </div>
      <div class="earn-card">
        <div class="ec-label">Gross Booking Amount</div>
        <div class="ec-value">₹<%= String.format("%,.0f", s.grossAmount) %></div>
        <div class="ec-note">Sum of all non-cancelled bookings</div>
      </div>
      <div class="earn-card highlight">
        <div class="ec-label">Your Net Earnings</div>
        <div class="ec-value">₹<%= String.format("%,.0f", s.netEarnings) %></div>
        <div class="ec-note">After <%= String.format("%.1f", s.commissionRate) %>% platform commission</div>
      </div>
      <div class="earn-card">
        <div class="ec-label">Completed Amount</div>
        <div class="ec-value">₹<%= String.format("%,.0f", s.completedAmount) %></div>
        <div class="ec-note">From completed bookings only</div>
      </div>
      <div class="earn-card">
        <div class="ec-label">Pending Amount</div>
        <div class="ec-value">₹<%= String.format("%,.0f", s.pendingAmount) %></div>
        <div class="ec-note">Bookings in progress</div>
      </div>
      <div class="earn-card">
        <div class="ec-label">Platform Commission</div>
        <div class="ec-value">₹<%= String.format("%,.0f", s.commissionAmount) %></div>
        <div class="ec-note">Platform cut (<%= String.format("%.1f", s.commissionRate) %>%)</div>
      </div>
    </div>

    <!-- ══ Breakdown panel ═══════════════════════════════════════ -->
    <div class="commission-panel">
      <h3>💰 Earnings Breakdown</h3>
      <div class="comm-row">
        <span class="cr-label">Gross Booking Amount</span>
        <span class="cr-value">₹<%= String.format("%,.2f", s.grossAmount) %></span>
      </div>
      <div class="comm-row">
        <span class="cr-label">Platform Commission (<%= String.format("%.1f", s.commissionRate) %>%)</span>
        <span class="cr-value" style="color:#b91c1c;">− ₹<%= String.format("%,.2f", s.commissionAmount) %></span>
      </div>
      <div class="comm-row net">
        <span class="cr-label">Your Net Earnings</span>
        <span class="cr-value">₹<%= String.format("%,.2f", s.netEarnings) %></span>
      </div>
      <div class="comm-note">
        * Commission rate of <strong><%= String.format("%.2f", s.commissionRate) %>%</strong>
        is read from the platform's commission configuration table.
        Calculated values are based on BOOKING_DETAILS; completed payouts are sourced
        from COMMISSION_DETAILS when available.
      </div>
    </div>

    <% } %>

    <!-- ══ Detail table ══════════════════════════════════════════ -->
    <div class="section-head" style="margin-bottom:18px;">
      <div>
        <div class="eyebrow">Booking Details</div>
        <h2 style="margin-top:6px;">Earning History</h2>
      </div>
    </div>

    <% if (detail == null || detail.isEmpty()) { %>
    <div class="empty-state">
      <div class="es-icon">💰</div>
      <h3>No earnings data yet</h3>
      <p>Earnings will appear here once your cars have confirmed bookings.</p>
    </div>
    <% } else { %>
    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th>Booking ID</th>
            <th>Customer</th>
            <th>Car</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>Gross (₹)</th>
            <th>Commission (₹)</th>
            <th>Net (₹)</th>
            <th>Status</th>
            <th>Payment</th>
          </tr>
        </thead>
        <tbody>
          <%
            double commRate = (s != null) ? s.commissionRate : 15.0;
            for (BookingRecord b : detail) {
              double comm = b.totalAmount * (commRate / 100.0);
              double net  = b.totalAmount - comm;
              String bBadge;
              switch (b.bookingStatus == null ? "" : b.bookingStatus) {
                case "COMPLETED":  bBadge = "badge-completed"; break;
                case "CONFIRMED":  bBadge = "badge-confirmed"; break;
                case "PENDING":    bBadge = "badge-pending";   break;
                default:           bBadge = "badge-na";
              }
              String pBadge = "PAID".equals(b.paymentStatus) ? "badge-paid" : "badge-na";
          %>
          <tr>
            <td><strong><%= b.bookingId %></strong></td>
            <td><%= b.customerName %></td>
            <td><%= b.carName %></td>
            <td><%= b.startDate %></td>
            <td><%= b.endDate %></td>
            <td><%= String.format("%,.2f", b.totalAmount) %></td>
            <td style="color:#b91c1c;"><%= String.format("%,.2f", comm) %></td>
            <td style="color:#15803d;font-weight:700;"><%= String.format("%,.2f", net) %></td>
            <td><span class="badge <%= bBadge %>"><%= b.bookingStatus %></span></td>
            <td><span class="badge <%= pBadge %>"><%= b.paymentStatus %></span></td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
    <% } %>

  </div>
</div>

<footer class="footer">
  <div class="shell">
    <span class="brand">CARVERSE</span>
    <span style="color:#6a7a73;">© 2026 CarVerse · Business Partner Portal</span>
  </div>
</footer>
</body>
</html>
