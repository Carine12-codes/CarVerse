<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, com.servlet.BusinessCarBean" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Manage Inventory | CarVerse</title>
  <link rel="stylesheet" href="assets/css/carverse.css">
  <style>
    .bp-page { padding: 48px 0 80px; }
    .bp-hero  {
      background: var(--deep); color: #fff;
      padding: 44px 0 40px;
    }
    .bp-hero .eyebrow { margin-bottom: 8px; }
    .bp-hero h1 { font-size: 34px; letter-spacing: -1.5px; margin: 0 0 6px; }
    .bp-hero h1 span { color: var(--green); }
    .bp-hero p  { color: #aec5b5; margin: 0; font-size: 14px; }

    .back-link {
      display: inline-flex; align-items: center; gap: 6px;
      font-size: 13px; font-weight: 700; color: var(--muted);
      margin-bottom: 28px;
    }
    .back-link:hover { color: var(--ink); }

    .alert { padding: 14px 18px; border-radius: 8px; font-size: 14px; font-weight: 600; margin-bottom: 22px; }
    .alert-error   { background: #fef2f2; border: 1px solid #fca5a5; color: #b91c1c; }
    .alert-success { background: #f0fdf4; border: 1px solid #86efac; color: #15803d; }

    /* ── Summary cards ─────────────────────────────────────────── */
    .inv-summary {
      display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px;
      margin-bottom: 32px;
    }
    .inv-card {
      background: #fff; border: 1px solid var(--line);
      border-radius: 12px; padding: 20px 18px;
    }
    .inv-card .ic-label {
      font-size: 11px; font-weight: 900; letter-spacing: 1px;
      text-transform: uppercase; color: var(--muted); margin-bottom: 6px;
    }
    .inv-card .ic-value {
      font-size: 36px; font-weight: 900; letter-spacing: -1.5px;
    }
    .ic-available   { border-top: 3px solid #22c55e; }
    .ic-booked      { border-top: 3px solid #3b82f6; }
    .ic-maintenance { border-top: 3px solid #f59e0b; }
    .ic-inactive    { border-top: 3px solid #9ca3af; }

    /* ── Table ─────────────────────────────────────────────────── */
    .data-table { width: 100%; border-collapse: collapse; background: #fff; border: 1px solid var(--line); border-radius: 12px; overflow: hidden; font-size: 13px; }
    .data-table th { background: #f4f7f4; padding: 12px 14px; text-align: left; font-size: 11px; font-weight: 900; text-transform: uppercase; letter-spacing: .8px; color: var(--muted); border-bottom: 1px solid var(--line); }
    .data-table td { padding: 13px 14px; border-bottom: 1px solid var(--line); vertical-align: middle; }
    .data-table tr:last-child td { border-bottom: none; }
    .data-table tr:hover td      { background: #f9fcf5; }

    .badge { display: inline-block; padding: 3px 10px; border-radius: 99px; font-size: 11px; font-weight: 900; letter-spacing: .5px; text-transform: uppercase; }
    .badge-available   { background: #dcfce7; color: #15803d; }
    .badge-booked      { background: #dbeafe; color: #1d4ed8; }
    .badge-maintenance { background: #fef9c3; color: #92400e; }
    .badge-inactive    { background: #f3f4f6; color: #6b7280; }

    /* ── Status update inline form ─────────────────────────────── */
    .status-form { display: flex; gap: 8px; align-items: center; }
    .status-form select {
      border: 1px solid var(--line); border-radius: 6px;
      padding: 6px 10px; font-size: 12px; background: #fbfdfb;
    }
    .btn-sm { border: 0; border-radius: 6px; padding: 7px 13px; font-size: 12px; font-weight: 800; cursor: pointer; background: var(--green); color: var(--ink); }
    .btn-sm:hover { opacity: .85; }

    .empty-state { text-align: center; padding: 56px 24px; background: #fff; border: 1px solid var(--line); border-radius: 12px; }
    .empty-state .es-icon { font-size: 44px; margin-bottom: 14px; }
    .empty-state h3 { font-size: 20px; margin: 0 0 8px; }
    .empty-state p  { color: var(--muted); font-size: 14px; }

    @media (max-width: 760px) { .inv-summary { grid-template-columns: 1fr 1fr; } }
    @media (max-width: 480px) { .inv-summary { grid-template-columns: 1fr; } }
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

  @SuppressWarnings("unchecked")
  List<BusinessCarBean> inventory = (List<BusinessCarBean>) request.getAttribute("inventoryList");
  int[] summary = (int[]) request.getAttribute("inventorySummary");
  if (summary == null) summary = new int[]{0,0,0,0};

  String errorMsg   = (String) request.getAttribute("error");
  String successMsg = (String) request.getParameter("success");
  if (successMsg == null) successMsg = (String) request.getAttribute("success");
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
    <div class="eyebrow">Business Partner · Fleet Management</div>
    <h1>Manage <span>Inventory</span></h1>
    <p>Track car availability, set maintenance status, and keep your fleet up to date.</p>
  </div>
</div>

<!-- ── Main ────────────────────────────────────────────────────── -->
<div class="bp-page">
  <div class="shell">
    <a class="back-link" href="business-dashboard.jsp">← Back to Dashboard</a>

    <% if (errorMsg != null) { %>
      <div class="alert alert-error"><%= errorMsg %></div>
    <% } %>
    <% if (successMsg != null && !successMsg.isEmpty()) { %>
      <div class="alert alert-success"><%= successMsg %></div>
    <% } %>

    <!-- ══ Summary cards ═════════════════════════════════════════ -->
    <div class="inv-summary">
      <div class="inv-card ic-available">
        <div class="ic-label">Available</div>
        <div class="ic-value"><%= summary[0] %></div>
      </div>
      <div class="inv-card ic-booked">
        <div class="ic-label">Booked</div>
        <div class="ic-value"><%= summary[1] %></div>
      </div>
      <div class="inv-card ic-maintenance">
        <div class="ic-label">Maintenance</div>
        <div class="ic-value"><%= summary[2] %></div>
      </div>
      <div class="inv-card ic-inactive">
        <div class="ic-label">Inactive</div>
        <div class="ic-value"><%= summary[3] %></div>
      </div>
    </div>

    <!-- ══ Inventory table ═══════════════════════════════════════ -->
    <div class="section-head" style="margin-bottom:18px;">
      <div>
        <div class="eyebrow">Fleet Overview</div>
        <h2 style="margin-top:6px;">All Cars</h2>
      </div>
      <a href="BusinessCar?action=list" class="btn btn-dark">+ Add Car</a>
    </div>

    <% if (inventory == null || inventory.isEmpty()) { %>
    <div class="empty-state">
      <div class="es-icon">📦</div>
      <h3>No cars in your fleet yet</h3>
      <p>Register your first car from the <a href="BusinessCar?action=list">Manage Cars</a> page.</p>
    </div>
    <% } else { %>
    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th>Reg. No.</th>
            <th>Car Name</th>
            <th>Brand</th>
            <th>Fuel</th>
            <th>Location</th>
            <th>Price / Day</th>
            <th>Current Status</th>
            <th>Update Status</th>
          </tr>
        </thead>
        <tbody>
          <% for (BusinessCarBean c : inventory) {
               String statusBadge;
               switch (c.getAvailabilityStatus() == null ? "" : c.getAvailabilityStatus()) {
                 case "AVAILABLE":    statusBadge = "badge-available";    break;
                 case "BOOKED":       statusBadge = "badge-booked";       break;
                 case "MAINTENANCE":  statusBadge = "badge-maintenance";  break;
                 default:             statusBadge = "badge-inactive";
               }
               // BOOKED status is managed by the booking flow — don't let partner change it
               boolean canChangeStatus = !"BOOKED".equals(c.getAvailabilityStatus());
          %>
          <tr>
            <td><strong><%= c.getRegistrationNumber() %></strong></td>
            <td><%= c.getCarName() %></td>
            <td><%= c.getBrand() %></td>
            <td><%= c.getFuelType() == null ? "—" : c.getFuelType() %></td>
            <td><%= c.getLocation() == null ? "—" : c.getLocation() %></td>
            <td>₹<%= String.format("%,.0f", c.getPricePerDay()) %></td>
            <td><span class="badge <%= statusBadge %>"><%= c.getAvailabilityStatus() %></span></td>
            <td>
              <% if (canChangeStatus) { %>
              <form action="BusinessInventory" method="post" class="status-form">
                <input type="hidden" name="action" value="updateStatus">
                <input type="hidden" name="carId"  value="<%= c.getCarId() %>">
                <select name="newStatus">
                  <option value="AVAILABLE"   <%= "AVAILABLE".equals(c.getAvailabilityStatus())   ? "selected" : "" %>>Available</option>
                  <option value="MAINTENANCE" <%= "MAINTENANCE".equals(c.getAvailabilityStatus()) ? "selected" : "" %>>Maintenance</option>
                  <option value="INACTIVE"    <%= "INACTIVE".equals(c.getAvailabilityStatus())    ? "selected" : "" %>>Inactive</option>
                </select>
                <button type="submit" class="btn-sm">Update</button>
              </form>
              <% } else { %>
              <span style="font-size:12px;color:var(--muted);">Managed by booking</span>
              <% } %>
            </td>
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
