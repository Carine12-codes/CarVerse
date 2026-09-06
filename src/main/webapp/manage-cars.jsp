<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, com.servlet.BusinessCarBean" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Manage Cars | CarVerse</title>
  <link rel="stylesheet" href="assets/css/carverse.css">
  <style>
    /* ── Page layout ───────────────────────────────────────────── */
    .bp-page { padding: 48px 0 80px; }
    .bp-hero  {
      background: var(--deep); color: #fff;
      padding: 44px 0 40px; margin-bottom: 0;
    }
    .bp-hero .eyebrow { margin-bottom: 8px; }
    .bp-hero h1 { font-size: 34px; letter-spacing: -1.5px; margin: 0 0 6px; }
    .bp-hero h1 span { color: var(--green); }
    .bp-hero p  { color: #aec5b5; margin: 0; font-size: 14px; }

    /* ── Back link ─────────────────────────────────────────────── */
    .back-link {
      display: inline-flex; align-items: center; gap: 6px;
      font-size: 13px; font-weight: 700; color: var(--muted);
      margin-bottom: 28px;
    }
    .back-link:hover { color: var(--ink); }

    /* ── Alerts ────────────────────────────────────────────────── */
    .alert {
      padding: 14px 18px; border-radius: 8px; font-size: 14px;
      font-weight: 600; margin-bottom: 22px;
    }
    .alert-error   { background: #fef2f2; border: 1px solid #fca5a5; color: #b91c1c; }
    .alert-success { background: #f0fdf4; border: 1px solid #86efac; color: #15803d; }

    /* ── Section header ────────────────────────────────────────── */
    .sec-head {
      display: flex; justify-content: space-between; align-items: center;
      margin-bottom: 20px;
    }
    .sec-head h2 { font-size: 22px; letter-spacing: -.5px; margin: 0; }

    /* ── Cars table ────────────────────────────────────────────── */
    .data-table {
      width: 100%; border-collapse: collapse;
      background: #fff; border: 1px solid var(--line);
      border-radius: 12px; overflow: hidden;
      font-size: 13px;
    }
    .data-table th {
      background: #f4f7f4; padding: 12px 14px; text-align: left;
      font-size: 11px; font-weight: 900; text-transform: uppercase;
      letter-spacing: .8px; color: var(--muted);
      border-bottom: 1px solid var(--line);
    }
    .data-table td {
      padding: 13px 14px; border-bottom: 1px solid var(--line);
      vertical-align: middle; color: var(--ink);
    }
    .data-table tr:last-child td { border-bottom: none; }
    .data-table tr:hover td      { background: #f9fcf5; }

    /* ── Status badges ─────────────────────────────────────────── */
    .badge {
      display: inline-block; padding: 3px 10px; border-radius: 99px;
      font-size: 11px; font-weight: 900; letter-spacing: .5px;
      text-transform: uppercase;
    }
    .badge-available   { background: #dcfce7; color: #15803d; }
    .badge-booked      { background: #dbeafe; color: #1d4ed8; }
    .badge-maintenance { background: #fef9c3; color: #92400e; }
    .badge-inactive    { background: #f3f4f6; color: #6b7280; }

    /* ── Action buttons ────────────────────────────────────────── */
    .btn-sm {
      border: 0; border-radius: 6px; padding: 7px 13px;
      font-size: 12px; font-weight: 800; cursor: pointer;
    }
    .btn-edit   { background: #f0fdf4; color: #15803d; border: 1px solid #86efac; }
    .btn-toggle { background: #eff6ff; color: #1d4ed8; border: 1px solid #93c5fd; }
    .btn-del    { background: #fef2f2; color: #b91c1c; border: 1px solid #fca5a5; }
    .btn-edit:hover   { background: #dcfce7; }
    .btn-toggle:hover { background: #dbeafe; }
    .btn-del:hover    { background: #fee2e2; }

    /* ── Add / Edit form panel ─────────────────────────────────── */
    .form-panel {
      background: #fff; border: 1px solid var(--line);
      border-radius: 13px; padding: 30px 28px; margin-bottom: 32px;
    }
    .form-panel h3 {
      font-size: 18px; letter-spacing: -.4px; margin: 0 0 22px;
    }
    .form-grid {
      display: grid; grid-template-columns: 1fr 1fr; gap: 16px;
    }
    .form-grid.three { grid-template-columns: 1fr 1fr 1fr; }
    .field-wrap { display: flex; flex-direction: column; gap: 6px; }
    .field-wrap label {
      font-size: 11px; font-weight: 900; letter-spacing: .6px;
      text-transform: uppercase; color: var(--muted);
    }
    .field-wrap input, .field-wrap select {
      border: 1px solid var(--line); background: #fbfdfb;
      border-radius: 7px; padding: 11px 13px; font-size: 14px;
      color: var(--ink); outline: none;
    }
    .field-wrap input:focus, .field-wrap select:focus {
      border-color: #8bd024;
    }
    .form-actions { display: flex; gap: 10px; margin-top: 22px; }
    .full-span    { grid-column: 1 / -1; }

    /* ── Empty state ───────────────────────────────────────────── */
    .empty-state {
      text-align: center; padding: 56px 24px;
      background: #fff; border: 1px solid var(--line); border-radius: 12px;
    }
    .empty-state .es-icon { font-size: 44px; margin-bottom: 14px; }
    .empty-state h3 { font-size: 20px; margin: 0 0 8px; }
    .empty-state p  { color: var(--muted); font-size: 14px; }

    @media (max-width: 700px) {
      .form-grid, .form-grid.three { grid-template-columns: 1fr; }
    }
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

  String mode    = (String) request.getAttribute("mode");
  if (mode == null) mode = "list";
  BusinessCarBean editCar  = (BusinessCarBean) request.getAttribute("editCar");
  BusinessCarBean formCar  = (BusinessCarBean) request.getAttribute("formCar");
  // formCar repopulates add form on validation error
  if (formCar == null) formCar = new BusinessCarBean();

  @SuppressWarnings("unchecked")
  List<BusinessCarBean> cars = (List<BusinessCarBean>) request.getAttribute("cars");

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
    <div class="eyebrow">Business Partner · Manage Cars</div>
    <h1>Your <span>Fleet</span></h1>
    <p>Register, edit, and manage the cars listed under your account.</p>
  </div>
</div>

<!-- ── Main content ────────────────────────────────────────────── -->
<div class="bp-page">
  <div class="shell">

    <a class="back-link" href="business-dashboard.jsp">← Back to Dashboard</a>

    <% if (errorMsg != null) { %>
      <div class="alert alert-error"><%= errorMsg %></div>
    <% } %>
    <% if (successMsg != null && !successMsg.isEmpty()) { %>
      <div class="alert alert-success"><%= successMsg %></div>
    <% } %>

    <!-- ══ EDIT FORM (shown when mode=edit) ══════════════════════ -->
    <% if ("edit".equals(mode) && editCar != null) { %>
    <div class="form-panel">
      <h3>✏️ Edit Car — <%= editCar.getCarName() %></h3>
      <form action="BusinessCar" method="post">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="carId"  value="<%= editCar.getCarId() %>">
        <div class="form-grid">
          <div class="field-wrap">
            <label>Car Name *</label>
            <input type="text" name="carName" value="<%= editCar.getCarName() %>" required>
          </div>
          <div class="field-wrap">
            <label>Brand *</label>
            <input type="text" name="brand" value="<%= editCar.getBrand() %>" required>
          </div>
          <div class="field-wrap">
            <label>Model *</label>
            <input type="text" name="model" value="<%= editCar.getModel() %>" required>
          </div>
          <div class="field-wrap">
            <label>Manufacturing Year *</label>
            <input type="number" name="manufacturingYear" min="1900" max="2100"
                   value="<%= editCar.getManufacturingYear() %>" required>
          </div>
          <div class="field-wrap">
            <label>Body Type</label>
            <select name="bodyType">
              <option value="">— Select —</option>
              <% for (String bt : new String[]{"SUV","Sedan","Hatchback","MUV","Coupe","Convertible","Pickup"}) {
                String sel = bt.equals(editCar.getBodyType()) ? "selected" : ""; %>
              <option value="<%= bt %>" <%= sel %>><%= bt %></option>
              <% } %>
            </select>
          </div>
          <div class="field-wrap">
            <label>Fuel Type</label>
            <select name="fuelType">
              <option value="">— Select —</option>
              <% for (String ft : new String[]{"Petrol","Diesel","Electric","Hybrid","CNG"}) {
                String sel = ft.equals(editCar.getFuelType()) ? "selected" : ""; %>
              <option value="<%= ft %>" <%= sel %>><%= ft %></option>
              <% } %>
            </select>
          </div>
          <div class="field-wrap">
            <label>Transmission</label>
            <select name="transmission">
              <option value="">— Select —</option>
              <% for (String tr : new String[]{"Manual","Automatic"}) {
                String sel = tr.equals(editCar.getTransmission()) ? "selected" : ""; %>
              <option value="<%= tr %>" <%= sel %>><%= tr %></option>
              <% } %>
            </select>
          </div>
          <div class="field-wrap">
            <label>Seating Capacity *</label>
            <input type="number" name="seatingCapacity" min="1" max="50"
                   value="<%= editCar.getSeatingCapacity() %>" required>
          </div>
          <div class="field-wrap">
            <label>Color</label>
            <input type="text" name="color" value="<%= editCar.getColor() == null ? "" : editCar.getColor() %>">
          </div>
          <div class="field-wrap">
            <label>Price Per Day (₹) *</label>
            <input type="number" name="pricePerDay" min="1" step="0.01"
                   value="<%= editCar.getPricePerDay() %>" required>
          </div>
          <div class="field-wrap full-span">
            <label>Location</label>
            <input type="text" name="location"
                   value="<%= editCar.getLocation() == null ? "" : editCar.getLocation() %>">
          </div>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Save Changes</button>
          <a href="BusinessCar?action=list" class="btn btn-outline">Cancel</a>
        </div>
      </form>
    </div>
    <% } %>

    <!-- ══ ADD NEW CAR FORM (always visible in list mode) ════════ -->
    <% if (!"edit".equals(mode)) { %>
    <div class="form-panel">
      <h3>🚗 Register a New Car</h3>
      <form action="BusinessCar" method="post">
        <input type="hidden" name="action" value="add">
        <div class="form-grid">
          <div class="field-wrap">
            <label>Registration Number *</label>
            <input type="text" name="registrationNumber"
                   value="<%= formCar.getRegistrationNumber() == null ? "" : formCar.getRegistrationNumber() %>"
                   placeholder="e.g. MH02AB1234" required>
          </div>
          <div class="field-wrap">
            <label>Car Name *</label>
            <input type="text" name="carName"
                   value="<%= formCar.getCarName() == null ? "" : formCar.getCarName() %>"
                   placeholder="e.g. Tata Nexon EV" required>
          </div>
          <div class="field-wrap">
            <label>Brand *</label>
            <input type="text" name="brand"
                   value="<%= formCar.getBrand() == null ? "" : formCar.getBrand() %>"
                   placeholder="e.g. Tata" required>
          </div>
          <div class="field-wrap">
            <label>Model *</label>
            <input type="text" name="model"
                   value="<%= formCar.getModel() == null ? "" : formCar.getModel() %>"
                   placeholder="e.g. Nexon EV Max" required>
          </div>
          <div class="field-wrap">
            <label>Manufacturing Year *</label>
            <input type="number" name="manufacturingYear" min="1900" max="2100"
                   value="<%= formCar.getManufacturingYear() == 0 ? "" : formCar.getManufacturingYear() %>"
                   placeholder="e.g. 2023" required>
          </div>
          <div class="field-wrap">
            <label>Body Type</label>
            <select name="bodyType">
              <option value="">— Select —</option>
              <% for (String bt : new String[]{"SUV","Sedan","Hatchback","MUV","Coupe","Convertible","Pickup"}) { %>
              <option value="<%= bt %>"><%= bt %></option>
              <% } %>
            </select>
          </div>
          <div class="field-wrap">
            <label>Fuel Type</label>
            <select name="fuelType">
              <option value="">— Select —</option>
              <% for (String ft : new String[]{"Petrol","Diesel","Electric","Hybrid","CNG"}) { %>
              <option value="<%= ft %>"><%= ft %></option>
              <% } %>
            </select>
          </div>
          <div class="field-wrap">
            <label>Transmission</label>
            <select name="transmission">
              <option value="">— Select —</option>
              <% for (String tr : new String[]{"Manual","Automatic"}) { %>
              <option value="<%= tr %>"><%= tr %></option>
              <% } %>
            </select>
          </div>
          <div class="field-wrap">
            <label>Seating Capacity *</label>
            <input type="number" name="seatingCapacity" min="1" max="50"
                   value="<%= formCar.getSeatingCapacity() == 0 ? "" : formCar.getSeatingCapacity() %>"
                   placeholder="e.g. 5" required>
          </div>
          <div class="field-wrap">
            <label>Color</label>
            <input type="text" name="color"
                   value="<%= formCar.getColor() == null ? "" : formCar.getColor() %>"
                   placeholder="e.g. Pearl White">
          </div>
          <div class="field-wrap">
            <label>Price Per Day (₹) *</label>
            <input type="number" name="pricePerDay" min="1" step="0.01"
                   value="<%= formCar.getPricePerDay() == 0 ? "" : formCar.getPricePerDay() %>"
                   placeholder="e.g. 2500" required>
          </div>
          <div class="field-wrap">
            <label>Location</label>
            <input type="text" name="location"
                   value="<%= formCar.getLocation() == null ? "" : formCar.getLocation() %>"
                   placeholder="e.g. Mumbai, Maharashtra">
          </div>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Register Car</button>
        </div>
      </form>
    </div>
    <% } %>

    <!-- ══ CAR LIST ═══════════════════════════════════════════════ -->
    <div class="sec-head">
      <h2>Your Cars
        <% if (cars != null) { %>
          <span style="font-size:14px;font-weight:400;color:var(--muted);margin-left:8px;">
            (<%= cars.size() %> registered)
          </span>
        <% } %>
      </h2>
    </div>

    <% if (cars == null || cars.isEmpty()) { %>
    <div class="empty-state">
      <div class="es-icon">🚗</div>
      <h3>No cars registered yet</h3>
      <p>Use the form above to register your first car on CarVerse.</p>
    </div>
    <% } else { %>
    <div style="overflow-x:auto;">
      <table class="data-table">
        <thead>
          <tr>
            <th>Reg. No.</th>
            <th>Car</th>
            <th>Brand / Model</th>
            <th>Year</th>
            <th>Fuel</th>
            <th>Transmission</th>
            <th>Seats</th>
            <th>Price / Day</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <% for (BusinessCarBean c : cars) {
               String statusBadge;
               switch (c.getAvailabilityStatus() == null ? "" : c.getAvailabilityStatus()) {
                 case "AVAILABLE":    statusBadge = "badge-available";    break;
                 case "BOOKED":       statusBadge = "badge-booked";       break;
                 case "MAINTENANCE":  statusBadge = "badge-maintenance";  break;
                 default:             statusBadge = "badge-inactive";
               }
               String toggleLabel = "AVAILABLE".equals(c.getAvailabilityStatus())
                   ? "Deactivate" : "Activate";
               boolean canToggle = "AVAILABLE".equals(c.getAvailabilityStatus())
                   || "INACTIVE".equals(c.getAvailabilityStatus());
          %>
          <tr>
            <td><strong><%= c.getRegistrationNumber() %></strong></td>
            <td><%= c.getCarName() %></td>
            <td><%= c.getBrand() %> <%= c.getModel() %></td>
            <td><%= c.getManufacturingYear() %></td>
            <td><%= c.getFuelType() == null ? "—" : c.getFuelType() %></td>
            <td><%= c.getTransmission() == null ? "—" : c.getTransmission() %></td>
            <td style="text-align:center;"><%= c.getSeatingCapacity() %></td>
            <td>₹<%= String.format("%,.0f", c.getPricePerDay()) %></td>
            <td><span class="badge <%= statusBadge %>"><%= c.getAvailabilityStatus() %></span></td>
            <td style="white-space:nowrap;">
              <!-- Edit -->
              <a href="BusinessCar?action=edit&carId=<%= c.getCarId() %>"
                 class="btn-sm btn-edit">Edit</a>

              <!-- Toggle availability -->
              <% if (canToggle) { %>
              <form action="BusinessCar" method="post" style="display:inline;">
                <input type="hidden" name="action" value="toggle">
                <input type="hidden" name="carId"  value="<%= c.getCarId() %>">
                <button type="submit" class="btn-sm btn-toggle"><%= toggleLabel %></button>
              </form>
              <% } %>

              <!-- Delete -->
              <form action="BusinessCar" method="post" style="display:inline;"
                    onsubmit="return confirm('Delete <%= c.getCarName().replace("'","\\x27") %>? This cannot be undone.');">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="carId"  value="<%= c.getCarId() %>">
                <button type="submit" class="btn-sm btn-del">Delete</button>
              </form>
            </td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
    <% } %>

  </div>
</div>

<!-- ── Footer ──────────────────────────────────────────────────── -->
<footer class="footer">
  <div class="shell">
    <span class="brand">CARVERSE</span>
    <span style="color:#6a7a73;">© 2026 CarVerse · Business Partner Portal</span>
  </div>
</footer>
</body>
</html>
