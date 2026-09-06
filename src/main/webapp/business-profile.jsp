<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.servlet.Business" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Business Profile | CarVerse</title>
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

    /* ── Profile layout ────────────────────────────────────────── */
    .profile-layout {
      display: grid; grid-template-columns: 280px 1fr; gap: 24px;
      align-items: start;
    }

    /* ── Info sidebar ──────────────────────────────────────────── */
    .profile-sidebar {
      background: #fff; border: 1px solid var(--line);
      border-radius: 13px; padding: 28px 22px;
      position: sticky; top: 90px;
    }
    .ps-avatar {
      width: 72px; height: 72px; border-radius: 50%;
      background: var(--deep); color: var(--green);
      font-size: 28px; font-weight: 900;
      display: flex; align-items: center; justify-content: center;
      margin-bottom: 14px;
    }
    .ps-name  { font-size: 18px; font-weight: 900; margin-bottom: 2px; }
    .ps-brand { font-size: 13px; color: var(--muted); margin-bottom: 16px; }
    .ps-divider { border: none; border-top: 1px solid var(--line); margin: 16px 0; }
    .ps-row   { display: flex; flex-direction: column; gap: 3px; margin-bottom: 12px; }
    .ps-row-label { font-size: 10px; font-weight: 900; text-transform: uppercase; letter-spacing: .7px; color: var(--muted); }
    .ps-row-value { font-size: 13px; color: var(--ink); word-break: break-word; }

    .status-badge { display: inline-block; padding: 3px 10px; border-radius: 99px; font-size: 11px; font-weight: 900; text-transform: uppercase; }
    .status-active    { background: #dcfce7; color: #15803d; }
    .status-pending   { background: #fef9c3; color: #92400e; }
    .status-suspended { background: #fef2f2; color: #b91c1c; }

    /* ── Edit form ─────────────────────────────────────────────── */
    .profile-form {
      background: #fff; border: 1px solid var(--line);
      border-radius: 13px; padding: 30px 28px;
    }
    .form-section { margin-bottom: 30px; }
    .form-section-title {
      font-size: 13px; font-weight: 900; text-transform: uppercase;
      letter-spacing: .8px; color: var(--green); margin-bottom: 16px;
      padding-bottom: 8px; border-bottom: 1px solid var(--line);
    }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .field-wrap { display: flex; flex-direction: column; gap: 6px; }
    .field-wrap label { font-size: 11px; font-weight: 900; letter-spacing: .6px; text-transform: uppercase; color: var(--muted); }
    .field-wrap input, .field-wrap select, .field-wrap textarea {
      border: 1px solid var(--line); background: #fbfdfb;
      border-radius: 7px; padding: 11px 13px; font-size: 14px;
      color: var(--ink); outline: none; font-family: inherit;
    }
    .field-wrap input:focus, .field-wrap textarea:focus { border-color: #8bd024; }
    .field-wrap input[readonly] { background: #f4f7f4; color: var(--muted); cursor: not-allowed; }
    .field-wrap textarea { resize: vertical; min-height: 80px; }
    .full-span { grid-column: 1 / -1; }
    .hint { font-size: 11px; color: var(--muted); }

    .form-actions { display: flex; gap: 10px; margin-top: 24px; padding-top: 20px; border-top: 1px solid var(--line); }

    @media (max-width: 900px) { .profile-layout { grid-template-columns: 1fr; } .profile-sidebar { position: static; } }
    @media (max-width: 600px) { .form-grid { grid-template-columns: 1fr; } }
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

  Business p = (Business) request.getAttribute("profile");
  String errorMsg   = (String) request.getAttribute("error");
  String successMsg = (String) request.getParameter("success");
  if (successMsg == null) successMsg = (String) request.getAttribute("success");

  // Helper to safely output a field value (empty string if null)
  // We use a simple inline ternary in the JSP for each field
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
    <div class="eyebrow">Business Partner · Account</div>
    <h1>Business <span>Profile</span></h1>
    <p>View and update your business information, contact details, and branding.</p>
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

    <% if (p == null) { %>
    <div style="text-align:center;padding:60px 0;color:var(--muted);">
      Could not load profile. <a href="BusinessProfile">Try again</a>
    </div>
    <% } else {
        String statusBadge = "ACTIVE".equals(p.getAccountStatus()) ? "status-active"
            : "PENDING".equals(p.getAccountStatus()) ? "status-pending" : "status-suspended";
        String initials = "";
        if (p.getBusinessName() != null && !p.getBusinessName().isEmpty()) {
          String[] parts = p.getBusinessName().trim().split("\\s+");
          initials += parts[0].charAt(0);
          if (parts.length > 1) initials += parts[parts.length-1].charAt(0);
        }
    %>
    <div class="profile-layout">

      <!-- ── Sidebar ────────────────────────────────────────────── -->
      <div class="profile-sidebar">
        <div class="ps-avatar"><%= initials.toUpperCase() %></div>
        <div class="ps-name"><%= p.getBusinessName() %></div>
        <div class="ps-brand"><%= p.getBrandName() != null ? p.getBrandName() : "" %></div>
        <span class="status-badge <%= statusBadge %>"><%= p.getAccountStatus() %></span>
        <hr class="ps-divider">
        <div class="ps-row">
          <span class="ps-row-label">Partner ID</span>
          <span class="ps-row-value"><%= p.getBusinessId() %></span>
        </div>
        <div class="ps-row">
          <span class="ps-row-label">Login Email</span>
          <span class="ps-row-value"><%= p.getLoginEmail() %></span>
        </div>
        <div class="ps-row">
          <span class="ps-row-label">Member Since</span>
          <span class="ps-row-value"><%= p.getCreatedAt() != null ? p.getCreatedAt() : "—" %></span>
        </div>
        <div class="ps-row">
          <span class="ps-row-label">Last Updated</span>
          <span class="ps-row-value"><%= p.getUpdatedAt() != null ? p.getUpdatedAt() : "—" %></span>
        </div>
      </div>

      <!-- ── Edit form ──────────────────────────────────────────── -->
      <div class="profile-form">
        <form action="BusinessProfile" method="post">

          <!-- Section A: Business Info -->
          <div class="form-section">
            <div class="form-section-title">Section A — Business Information</div>
            <div class="form-grid">
              <div class="field-wrap">
                <label>Business Name *</label>
                <input type="text" name="businessName"
                       value="<%= p.getBusinessName() != null ? p.getBusinessName() : "" %>" required>
              </div>
              <div class="field-wrap">
                <label>Brand Name *</label>
                <input type="text" name="brandName"
                       value="<%= p.getBrandName() != null ? p.getBrandName() : "" %>" required>
              </div>
              <div class="field-wrap">
                <label>Business Email *</label>
                <input type="email" name="businessEmail"
                       value="<%= p.getBusinessEmail() != null ? p.getBusinessEmail() : "" %>" required>
              </div>
              <div class="field-wrap">
                <label>Business Phone *</label>
                <input type="tel" name="businessPhone"
                       value="<%= p.getBusinessPhone() != null ? p.getBusinessPhone() : "" %>"
                       placeholder="10-digit number" required>
              </div>
              <div class="field-wrap">
                <label>CIN / Registration No.</label>
                <input type="text" name="registrationNo"
                       value="<%= p.getRegistrationNo() != null ? p.getRegistrationNo() : "" %>">
              </div>
              <div class="field-wrap">
                <label>GSTIN</label>
                <input type="text" name="gstin"
                       value="<%= p.getGstin() != null ? p.getGstin() : "" %>">
              </div>
              <div class="field-wrap">
                <label>PAN</label>
                <input type="text" name="pan"
                       value="<%= p.getPan() != null ? p.getPan() : "" %>">
              </div>
              <div class="field-wrap">
                <label>Website</label>
                <input type="url" name="website"
                       value="<%= p.getWebsite() != null ? p.getWebsite() : "" %>"
                       placeholder="https://example.com">
              </div>
              <div class="field-wrap full-span">
                <label>Address *</label>
                <textarea name="address" required><%= p.getAddress() != null ? p.getAddress() : "" %></textarea>
              </div>
              <div class="field-wrap">
                <label>City *</label>
                <input type="text" name="city"
                       value="<%= p.getCity() != null ? p.getCity() : "" %>" required>
              </div>
              <div class="field-wrap">
                <label>State *</label>
                <input type="text" name="state"
                       value="<%= p.getState() != null ? p.getState() : "" %>" required>
              </div>
              <div class="field-wrap">
                <label>PIN Code *</label>
                <input type="text" name="pinCode" maxlength="6" pattern="\d{6}"
                       value="<%= p.getPinCode() != null ? p.getPinCode() : "" %>"
                       placeholder="6-digit PIN" required>
              </div>
            </div>
          </div>

          <!-- Section B: Authorized Contact -->
          <div class="form-section">
            <div class="form-section-title">Section B — Authorized Contact</div>
            <div class="form-grid">
              <div class="field-wrap">
                <label>Contact Person Name *</label>
                <input type="text" name="contactPersonName"
                       value="<%= p.getContactPersonName() != null ? p.getContactPersonName() : "" %>" required>
              </div>
              <div class="field-wrap">
                <label>Designation</label>
                <input type="text" name="contactPersonDesignation"
                       value="<%= p.getContactPersonDesignation() != null ? p.getContactPersonDesignation() : "" %>">
              </div>
              <div class="field-wrap">
                <label>Contact Email *</label>
                <input type="email" name="contactPersonEmail"
                       value="<%= p.getContactPersonEmail() != null ? p.getContactPersonEmail() : "" %>" required>
              </div>
              <div class="field-wrap">
                <label>Contact Phone *</label>
                <input type="tel" name="contactPersonPhone"
                       value="<%= p.getContactPersonPhone() != null ? p.getContactPersonPhone() : "" %>"
                       placeholder="10-digit number" required>
              </div>
            </div>
          </div>

          <!-- Section C: Read-only login info -->
          <div class="form-section">
            <div class="form-section-title">Section C — Login Credentials</div>
            <div class="form-grid">
              <div class="field-wrap">
                <label>Login Email</label>
                <input type="email" value="<%= p.getLoginEmail() != null ? p.getLoginEmail() : "" %>" readonly>
                <span class="hint">Login email cannot be changed here. Contact support to update it.</span>
              </div>
              <div class="field-wrap">
                <label>Password</label>
                <input type="text" value="••••••••••" readonly>
                <span class="hint">Password changes are not supported in this portal version.</span>
              </div>
            </div>
          </div>

          <div class="form-actions">
            <button type="submit" class="btn btn-primary">Save Changes</button>
            <a href="BusinessProfile" class="btn btn-outline">Discard</a>
          </div>
        </form>
      </div>

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
