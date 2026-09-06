<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, com.servlet.BusinessDAO.BookingRecord" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>View Bookings | CarVerse</title>
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
    .alert-error   { background: #fef2f2; border: 1px solid #fca5a5; color: #b91c1c; }
    .alert-success { background: #f0fdf4; border: 1px solid #86efac; color: #15803d; }

    /* ── Pending cancellation notice ───────────────────────────── */
    .cancel-notice {
      display: flex; align-items: center; gap: 12px;
      background: #fffbeb; border: 1px solid #fcd34d;
      border-radius: 10px; padding: 14px 18px; margin-bottom: 22px;
      font-size: 14px; font-weight: 600; color: #92400e;
    }
    .cancel-notice .cn-count {
      background: #f59e0b; color: #fff;
      border-radius: 99px; padding: 2px 9px; font-size: 12px;
    }

    /* ── Filter bar ────────────────────────────────────────────── */
    .filter-bar {
      display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 22px;
    }
    .filter-btn {
      padding: 8px 16px; border-radius: 99px; font-size: 12px;
      font-weight: 800; border: 1px solid var(--line);
      background: #fff; color: var(--muted); cursor: pointer;
      text-decoration: none;
    }
    .filter-btn:hover { border-color: #8bd024; color: var(--ink); }
    .filter-btn.active { background: var(--deep); color: #fff; border-color: var(--deep); }

    /* ── Booking cards ─────────────────────────────────────────── */
    .booking-card {
      background: #fff; border: 1px solid var(--line);
      border-radius: 13px; margin-bottom: 16px; overflow: hidden;
    }
    .booking-card.has-cancel-request { border-color: #fcd34d; border-width: 2px; }

    .bc-header {
      display: flex; justify-content: space-between; align-items: center;
      padding: 16px 20px; border-bottom: 1px solid var(--line);
      background: #fafcfa;
    }
    .bc-header-left { display: flex; gap: 12px; align-items: center; }
    .bc-id  { font-size: 13px; font-weight: 900; color: var(--ink); }
    .bc-date { font-size: 12px; color: var(--muted); }

    .bc-body {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 0;
      padding: 18px 20px;
    }
    .bc-field { padding: 6px 12px 6px 0; }
    .bc-field-label { font-size: 11px; font-weight: 900; letter-spacing: .6px; text-transform: uppercase; color: var(--muted); margin-bottom: 3px; }
    .bc-field-value { font-size: 13px; color: var(--ink); font-weight: 600; }

    /* ── Cancellation section (inline) ─────────────────────────── */
    .cancel-section {
      background: #fffbeb; border-top: 1px solid #fcd34d;
      padding: 16px 20px;
    }
    .cancel-section h4 {
      font-size: 13px; font-weight: 900; color: #92400e;
      margin: 0 0 6px; text-transform: uppercase; letter-spacing: .6px;
    }
    .cancel-reason {
      font-size: 13px; color: #78350f; background: #fff;
      border: 1px solid #fcd34d; border-radius: 7px;
      padding: 10px 14px; margin-bottom: 12px;
    }
    .cancel-actions { display: flex; gap: 10px; }
    .btn-approve { background: #dcfce7; color: #15803d; border: 1px solid #86efac; border-radius: 7px; padding: 9px 18px; font-size: 13px; font-weight: 800; cursor: pointer; }
    .btn-approve:hover { background: #bbf7d0; }
    .btn-reject  { background: #fef2f2; color: #b91c1c; border: 1px solid #fca5a5; border-radius: 7px; padding: 9px 18px; font-size: 13px; font-weight: 800; cursor: pointer; }
    .btn-reject:hover  { background: #fee2e2; }

    /* ── Badges ────────────────────────────────────────────────── */
    .badge { display: inline-block; padding: 3px 10px; border-radius: 99px; font-size: 11px; font-weight: 900; letter-spacing: .5px; text-transform: uppercase; }
    .badge-confirmed  { background: #dcfce7; color: #15803d; }
    .badge-pending    { background: #fef9c3; color: #92400e; }
    .badge-completed  { background: #dbeafe; color: #1d4ed8; }
    .badge-cancelled  { background: #f3f4f6; color: #6b7280; }
    .badge-requested  { background: #fef9c3; color: #92400e; }
    .badge-approved   { background: #dcfce7; color: #15803d; }
    .badge-rejected   { background: #f3f4f6; color: #6b7280; }
    .badge-paid       { background: #dcfce7; color: #15803d; }
    .badge-unpaid     { background: #fef2f2; color: #b91c1c; }
    .badge-na         { background: #f3f4f6; color: #9ca3af; }

    .empty-state { text-align: center; padding: 56px 24px; background: #fff; border: 1px solid var(--line); border-radius: 12px; }
    .empty-state .es-icon { font-size: 44px; margin-bottom: 14px; }
    .empty-state h3 { font-size: 20px; margin: 0 0 8px; }
    .empty-state p  { color: var(--muted); font-size: 14px; }

    @media (max-width: 700px) { .bc-body { grid-template-columns: 1fr 1fr; } }
    @media (max-width: 480px) { .bc-body { grid-template-columns: 1fr; } }
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
  List<BookingRecord> bookings = (List<BookingRecord>) request.getAttribute("bookings");
  String statusFilter  = (String) request.getAttribute("statusFilter");
  Integer pendingCancelAttr = (Integer) request.getAttribute("pendingCancels");
  int pendingCancels   = pendingCancelAttr != null ? pendingCancelAttr : 0;

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
    <div class="eyebrow">Business Partner · Bookings</div>
    <h1>View <span>Bookings</span></h1>
    <p>All bookings for your registered cars — including cancellation requests.</p>
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

    <!-- Pending cancellation notice -->
    <% if (pendingCancels > 0) { %>
    <div class="cancel-notice">
      ⚠️ You have
      <span class="cn-count"><%= pendingCancels %></span>
      pending cancellation request<%= pendingCancels > 1 ? "s" : "" %> waiting for your review.
    </div>
    <% } %>

    <!-- ══ Filter tabs ═══════════════════════════════════════════ -->
    <div class="filter-bar">
      <a href="BusinessBookings" class="filter-btn <%= statusFilter == null ? "active" : "" %>">All</a>
      <a href="BusinessBookings?status=CONFIRMED"  class="filter-btn <%= "CONFIRMED".equals(statusFilter)  ? "active" : "" %>">Confirmed</a>
      <a href="BusinessBookings?status=PENDING"    class="filter-btn <%= "PENDING".equals(statusFilter)    ? "active" : "" %>">Pending</a>
      <a href="BusinessBookings?status=COMPLETED"  class="filter-btn <%= "COMPLETED".equals(statusFilter)  ? "active" : "" %>">Completed</a>
      <a href="BusinessBookings?status=CANCELLED"  class="filter-btn <%= "CANCELLED".equals(statusFilter)  ? "active" : "" %>">Cancelled</a>
    </div>

    <!-- ══ Booking cards ═════════════════════════════════════════ -->
    <% if (bookings == null || bookings.isEmpty()) { %>
    <div class="empty-state">
      <div class="es-icon">📋</div>
      <h3>No bookings found</h3>
      <p>
        <% if (statusFilter != null) { %>
          No bookings with status "<strong><%= statusFilter %></strong>".
          <a href="BusinessBookings">View all bookings</a>
        <% } else { %>
          Bookings will appear here once customers book your cars.
        <% } %>
      </p>
    </div>
    <% } else { %>

      <div class="section-head" style="margin-bottom:18px;">
        <div>
          <div class="eyebrow"><%= bookings.size() %> booking<%= bookings.size() != 1 ? "s" : "" %> found</div>
        </div>
      </div>

      <% for (BookingRecord b : bookings) {
           boolean hasCancelRequest = "REQUESTED".equals(b.cancellationStatus);
           String bookingBadgeClass;
           switch (b.bookingStatus == null ? "" : b.bookingStatus) {
             case "CONFIRMED":  bookingBadgeClass = "badge-confirmed";  break;
             case "PENDING":    bookingBadgeClass = "badge-pending";    break;
             case "COMPLETED":  bookingBadgeClass = "badge-completed";  break;
             case "CANCELLED":  bookingBadgeClass = "badge-cancelled";  break;
             default:           bookingBadgeClass = "badge-na";
           }
           String cancelBadgeClass;
           switch (b.cancellationStatus == null ? "NONE" : b.cancellationStatus) {
             case "REQUESTED": cancelBadgeClass = "badge-requested"; break;
             case "APPROVED":  cancelBadgeClass = "badge-approved";  break;
             case "REJECTED":  cancelBadgeClass = "badge-rejected";  break;
             default:          cancelBadgeClass = "badge-na";
           }
           String payBadgeClass;
           switch (b.paymentStatus == null ? "" : b.paymentStatus) {
             case "PAID":    payBadgeClass = "badge-paid";   break;
             case "PENDING": payBadgeClass = "badge-pending"; break;
             case "N/A":     payBadgeClass = "badge-na";     break;
             default:        payBadgeClass = "badge-na";
           }
      %>
      <div class="booking-card <%= hasCancelRequest ? "has-cancel-request" : "" %>">

        <!-- Card header -->
        <div class="bc-header">
          <div class="bc-header-left">
            <span class="bc-id"># <%= b.bookingId %></span>
            <span class="badge <%= bookingBadgeClass %>"><%= b.bookingStatus %></span>
            <% if (!"NONE".equals(b.cancellationStatus) && b.cancellationStatus != null) { %>
              <span class="badge <%= cancelBadgeClass %>">Cancel: <%= b.cancellationStatus %></span>
            <% } %>
          </div>
          <span class="bc-date">Booked: <%= b.bookingDate %></span>
        </div>

        <!-- Card body -->
        <div class="bc-body">
          <div class="bc-field">
            <div class="bc-field-label">Customer</div>
            <div class="bc-field-value"><%= b.customerName %></div>
          </div>
          <div class="bc-field">
            <div class="bc-field-label">Car</div>
            <div class="bc-field-value"><%= b.carName %></div>
          </div>
          <div class="bc-field">
            <div class="bc-field-label">Reg. No.</div>
            <div class="bc-field-value"><%= b.registrationNo %></div>
          </div>
          <div class="bc-field">
            <div class="bc-field-label">From</div>
            <div class="bc-field-value"><%= b.startDate %></div>
          </div>
          <div class="bc-field">
            <div class="bc-field-label">To</div>
            <div class="bc-field-value"><%= b.endDate %></div>
          </div>
          <div class="bc-field">
            <div class="bc-field-label">Total Amount</div>
            <div class="bc-field-value">₹<%= String.format("%,.2f", b.totalAmount) %></div>
          </div>
          <div class="bc-field">
            <div class="bc-field-label">Pickup</div>
            <div class="bc-field-value"><%= b.pickupLocation == null ? "—" : b.pickupLocation %></div>
          </div>
          <div class="bc-field">
            <div class="bc-field-label">Drop</div>
            <div class="bc-field-value"><%= b.dropLocation == null ? "—" : b.dropLocation %></div>
          </div>
          <div class="bc-field">
            <div class="bc-field-label">Payment</div>
            <div class="bc-field-value"><span class="badge <%= payBadgeClass %>"><%= b.paymentStatus %></span></div>
          </div>
        </div>

        <!-- ── Inline cancellation section ─────────────────────── -->
        <% if (hasCancelRequest) { %>
        <div class="cancel-section">
          <h4>↩️ Cancellation Request</h4>
          <div class="cancel-reason">
            <strong>Customer reason:</strong>
            <%= b.cancellationReason == null || b.cancellationReason.isEmpty()
                ? "No reason provided." : b.cancellationReason %>
          </div>
          <div class="cancel-actions">
            <form action="BusinessBookings" method="post" style="margin:0;"
                  onsubmit="return confirm('Approve this cancellation? The booking will be cancelled.');">
              <input type="hidden" name="action"    value="approveCancellation">
              <input type="hidden" name="bookingId" value="<%= b.bookingId %>">
              <button type="submit" class="btn-approve">✓ Approve Cancellation</button>
            </form>
            <form action="BusinessBookings" method="post" style="margin:0;"
                  onsubmit="return confirm('Reject this cancellation request? The booking will continue.');">
              <input type="hidden" name="action"    value="rejectCancellation">
              <input type="hidden" name="bookingId" value="<%= b.bookingId %>">
              <button type="submit" class="btn-reject">✗ Reject Request</button>
            </form>
          </div>
        </div>
        <% } %>
        <!-- Show resolved cancellation info if already processed -->
        <% if ("APPROVED".equals(b.cancellationStatus) || "REJECTED".equals(b.cancellationStatus)) { %>
        <div style="padding: 10px 20px; background: #f9fcf5; border-top: 1px solid var(--line); font-size: 12px; color: var(--muted);">
          Cancellation <%= b.cancellationStatus.toLowerCase() %> on <%= b.cancellationDate %>.
        </div>
        <% } %>

      </div>
      <% } %>

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
