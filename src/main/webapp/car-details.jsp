<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.servlet.CarModel" %>

<%
    CarModel car  = (CarModel) request.getAttribute("car");
    String errorMsg = (String) request.getAttribute("error");

    /* ------------------------------------------------------------------ *
     * Derived display values – computed once, reused throughout the page.
     * ------------------------------------------------------------------ */

    String fullName    = "";
    String firstImage  = "assets/images/car-placeholder.jpg";
    String[] allImages = new String[0];

    if (car != null) {

        fullName = (car.getBrand() != null ? car.getBrand() : "")
                 + " "
                 + (car.getModelName() != null ? car.getModelName() : "");
        fullName = fullName.trim();

        /* Split comma-separated image list */
        if (car.getImages() != null && !car.getImages().trim().isEmpty()) {
            allImages = car.getImages().split(",");
            for (int i = 0; i < allImages.length; i++) {
                allImages[i] = allImages[i].trim();
            }
            if (allImages.length > 0 && !allImages[0].isEmpty()) {
                firstImage = allImages[0];
            }
        }
    }

    /* Helper: show value or em-dash when null / blank */
%>
<%!
    private String val(String s) {
        return (s != null && !s.trim().isEmpty()) ? s.trim() : "—";
    }
%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>
        <%= car != null ? fullName + " | CarVerse" : "Car Details | CarVerse" %>
    </title>

    <link rel="stylesheet" href="assets/css/carverse.css">
</head>
<body>

<!-- =========================================================
     NAVIGATION
     ========================================================= -->

<nav class="nav">
    <div class="shell">

        <a class="brand" href="index.jsp">CARVERSE</a>

        <div class="navlinks">
            <a href="index.jsp">Explore</a>
            <a class="active" href="<%= request.getContextPath() %>/car-search">New Cars</a>
            <a href="compare.jsp">Compare</a>
            <a href="index.jsp#ownership">Ownership</a>
        </div>

          <%
                String userName = (String) session.getAttribute("USERNAME");
                String userId = (String) session.getAttribute("USERID");

                if (userName == null || userId == null) {
            %>

                <!-- User is not logged in -->
                <a class="btn btn-outline" href="login.html">Sign in</a>

                <a class="btn btn-primary" href="user_registration.html">
                    Sign up →
                </a>

            <%
                } else {
            %>

                <!-- Logged-in user -->
                <a class="user-name" href="view_profile">
                    Welcome, <%= userName %>
                </a>

            <%
                }
            %>

    </div>
</nav>


<!-- =========================================================
     ERROR STATE
     ========================================================= -->

<% if (errorMsg != null) { %>

<main class="details-page">
    <div class="shell">
        <div class="breadcrumbs">
            <a href="index.jsp">Home</a>
            <span>/</span>
            <a href="<%= request.getContextPath() %>/car-search">New cars</a>
        </div>

        <div class="detail-section" style="text-align:center;padding:60px 28px;">
            <h2>Something went wrong</h2>
            <p style="color:var(--muted);margin:12px 0 24px;"><%= errorMsg %></p>
            <a class="btn btn-primary"
               href="<%= request.getContextPath() %>/car-search">
                ← Back to search
            </a>
        </div>
    </div>
</main>

<% } else if (car != null) { %>

<!-- =========================================================
     MAIN DETAILS PAGE
     ========================================================= -->

<main class="details-page">
    <div class="shell">

        <!-- Breadcrumbs -->

        <div class="breadcrumbs">
            <a href="index.jsp">Home</a>
            <span>/</span>
            <a href="<%= request.getContextPath() %>/car-search">New cars</a>
            <span>/</span>
            <%= fullName %>
        </div>


        <!-- =============================================================
             HERO — gallery + summary
             ============================================================= -->

        <section class="detail-hero">


            <!-- Gallery -->

            <div class="detail-gallery">

                <img class="primary-car-image"
                     id="main-car-image"
                     src="<%= firstImage %>"
                     alt="<%= fullName %>">

                <%-- Thumbnail strip: one button per image, max 5 shown --%>
                <% if (allImages.length > 1) { %>

                <div class="gallery-thumbs" id="gallery-thumbs">

                    <% for (int i = 0; i < Math.min(allImages.length, 5); i++) { %>

                        <button class="<%= i == 0 ? "selected" : "" %>"
                                data-src="<%= allImages[i] %>"
                                type="button">

                            Image <%= i + 1 %>

                        </button>

                    <% } %>

                </div>

                <% } %>

            </div>


            <!-- Summary -->

            <div class="detail-summary">

                <span class="tag">
                    <%= val(car.getBodyType()) %>
                    <% if (car.getFuelTypes() != null && !car.getFuelTypes().trim().isEmpty()) { %>
                        · <%= car.getFuelTypes() %>
                    <% } %>
                </span>

                <h1><%= fullName %></h1>

                <!-- Price -->

                <div class="detail-price">
                    <%= val(car.getPriceRange()) %><sup>*</sup>
                </div>

                <p class="on-road">Ex-showroom price</p>

                <% if (car.getSeatingCapacity() != null &&
                       !car.getSeatingCapacity().trim().isEmpty()) { %>

                    <div class="offer-inline">
                        ◌ &nbsp;<strong><%= car.getSeatingCapacity() %> seater</strong>
                        &nbsp;·&nbsp; <%= val(car.getDriveType()) %>
                    </div>

                <% } %>

                <!-- CTAs -->

                <div class="detail-ctas">
                    <a class="btn btn-primary" href="#offers">View offers →</a>
                    <a class="btn btn-outline"
                       href="<%= request.getContextPath() %>/BookingDisplayServlet?carId=<%= car.getCarId() %>">
                        Book Car
                    </a>
                </div>

                <p class="fine-print">*Ex-showroom price. Terms and conditions apply.</p>

            </div>

        </section>


        <!-- =============================================================
             SECTION TABS
             ============================================================= -->

        <nav class="detail-tabs">
            <a class="active" href="#overview">Overview</a>
            <a href="#specifications">Specifications</a>
            <a href="#offers">Offers</a>
            <% if (car.getFeatures() != null && !car.getFeatures().trim().isEmpty()) { %>
            <a href="#features">Features</a>
            <% } %>
            <a href="#reviews">Reviews</a>
        </nav>


        <!-- =============================================================
             TWO-COLUMN LAYOUT
             ============================================================= -->

        <div class="detail-layout">

            <!-- =========================================================
                 LEFT COLUMN
                 ========================================================= -->

            <div>


                <!-- ----------------------------------------------------- *
                     OVERVIEW
                     ----------------------------------------------------- -->

                <section class="detail-section" id="overview">

                    <div class="eyebrow">At a glance</div>
                    <h2><%= fullName %> — overview</h2>

                    <p class="sub">
                        The <%= fullName %> is a
                        <% if (car.getBodyType() != null) { %><%= car.getBodyType().toLowerCase() %><% } else { %>car<% } %>
                        <% if (car.getFuelTypes() != null && !car.getFuelTypes().trim().isEmpty()) { %>
                            with <%= car.getFuelTypes().toLowerCase() %> powertrain options
                        <% } %>
                        <% if (car.getPriceRange() != null && !car.getPriceRange().trim().isEmpty()) { %>
                            priced at <%= car.getPriceRange() %>
                        <% } %>.
                    </p>


                    <!-- Highlights strip -->

                    <div class="highlights">

                        <% if (car.getMileage() != null && !car.getMileage().trim().isEmpty()) { %>
                        <div>
                            <span>◎</span>
                            <strong><%= car.getMileage() %></strong>
                            <small>Mileage</small>
                        </div>
                        <% } %>

                        <% if (car.getEngine() != null && !car.getEngine().trim().isEmpty()) { %>
                        <div>
                            <span>⚙</span>
                            <strong><%= car.getEngine() %></strong>
                            <small>Engine</small>
                        </div>
                        <% } %>

                        <% if (car.getPower() != null && !car.getPower().trim().isEmpty()) { %>
                        <div>
                            <span>⚡</span>
                            <strong><%= car.getPower() %></strong>
                            <small>Power</small>
                        </div>
                        <% } %>

                        <% if (car.getSeatingCapacity() != null && !car.getSeatingCapacity().trim().isEmpty()) { %>
                        <div>
                            <span>◌</span>
                            <strong><%= car.getSeatingCapacity() %></strong>
                            <small>Seats</small>
                        </div>
                        <% } %>

                    </div>

                </section>


                <!-- ----------------------------------------------------- *
                     SPECIFICATIONS
                     ----------------------------------------------------- -->

                <section class="detail-section" id="specifications">

                    <div class="section-head">
                        <div>
                            <div class="eyebrow">Know the essentials</div>
                            <h2>Key specifications</h2>
                        </div>
                    </div>

                    <div class="details-spec-grid">

                        <div>
                            <span>Fuel type</span>
                            <b><%= val(car.getFuelTypes()) %></b>
                        </div>

                        <div>
                            <span>Engine</span>
                            <b><%= val(car.getEngine()) %></b>
                        </div>

                        <div>
                            <span>Power</span>
                            <b><%= val(car.getPower()) %></b>
                        </div>

                        <div>
                            <span>Torque</span>
                            <b><%= val(car.getTorque()) %></b>
                        </div>

                        <div>
                            <span>Drive type</span>
                            <b><%= val(car.getDriveType()) %></b>
                        </div>

                        <div>
                            <span>Mileage</span>
                            <b><%= val(car.getMileage()) %></b>
                        </div>

                        <div>
                            <span>Seating capacity</span>
                            <b><%= val(car.getSeatingCapacity()) %></b>
                        </div>

                        <div>
                            <span>Boot space</span>
                            <b><%= val(car.getBootSpace()) %></b>
                        </div>

                        <div>
                            <span>Safety rating</span>
                            <b><%= val(car.getSafetyRating()) %></b>
                        </div>

                    </div>


                    <!-- Dimensions sub-section -->

                    <% boolean hasDimensions =
                           (car.getLength()    != null && !car.getLength().trim().isEmpty())
                        || (car.getWidth()     != null && !car.getWidth().trim().isEmpty())
                        || (car.getHeight()    != null && !car.getHeight().trim().isEmpty())
                        || (car.getWheelbase() != null && !car.getWheelbase().trim().isEmpty());

                    if (hasDimensions) { %>

                    <h3 style="font-size:15px;margin:24px 0 12px;color:var(--muted);font-weight:800;letter-spacing:.5px;text-transform:uppercase;">
                        Dimensions
                    </h3>

                    <div class="details-spec-grid">

                        <% if (car.getLength() != null && !car.getLength().trim().isEmpty()) { %>
                        <div>
                            <span>Length</span>
                            <b><%= car.getLength() %></b>
                        </div>
                        <% } %>

                        <% if (car.getWidth() != null && !car.getWidth().trim().isEmpty()) { %>
                        <div>
                            <span>Width</span>
                            <b><%= car.getWidth() %></b>
                        </div>
                        <% } %>

                        <% if (car.getHeight() != null && !car.getHeight().trim().isEmpty()) { %>
                        <div>
                            <span>Height</span>
                            <b><%= car.getHeight() %></b>
                        </div>
                        <% } %>

                        <% if (car.getWheelbase() != null && !car.getWheelbase().trim().isEmpty()) { %>
                        <div>
                            <span>Wheelbase</span>
                            <b><%= car.getWheelbase() %></b>
                        </div>
                        <% } %>

                    </div>

                    <% } %>

                </section>


                <!-- ----------------------------------------------------- *
                     FEATURES
                     ----------------------------------------------------- -->

                <% if (car.getFeatures() != null && !car.getFeatures().trim().isEmpty()) { %>

                <section class="detail-section" id="features">

                    <div class="eyebrow">What's on board</div>
                    <h2>Features</h2>

                    <ul style="
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
                        gap: 10px;
                        list-style: none;
                        padding: 0;
                        margin: 16px 0 0;">

                        <%
                            String[] featureList = car.getFeatures().split(",");
                            for (String feature : featureList) {
                                feature = feature.trim();
                                if (!feature.isEmpty()) {
                        %>

                        <li style="
                            background: var(--mint);
                            border-left: 3px solid #7ec51e;
                            border-radius: 5px;
                            padding: 9px 12px;
                            font-size: 13px;
                            font-weight: 600;">
                            <%= feature %>
                        </li>

                        <%
                                }
                            }
                        %>

                    </ul>

                </section>

                <% } %>


                <!-- ----------------------------------------------------- *
                     REVIEWS (placeholder)
                     ----------------------------------------------------- -->

                <section class="detail-section review-section" id="reviews">

                    <div class="eyebrow">Owner voices</div>
                    <h2>What drivers are saying</h2>

                    <div class="review-card">
                        <div class="review-score">
                            —
                            <span>No reviews yet</span>
                        </div>
                        <div>
                            <p>Be the first to review the <%= fullName %>.</p>
                            <b>Reviews coming soon</b>
                        </div>
                    </div>

                </section>


            </div>


            <!-- =========================================================
                 RIGHT COLUMN — sticky sidebar
                 ========================================================= -->

            <aside class="sticky-side" id="offers">


                <!-- Offers card -->

                <section class="offer-card">

                    <div class="eyebrow">Pricing</div>
                    <h2>Get the best deal.</h2>

                    <div class="offer-row">
                        <span>Ex-showroom price</span>
                        <b><%= val(car.getPriceRange()) %></b>
                    </div>

                    <div class="offer-row">
                        <span>Body type</span>
                        <b><%= val(car.getBodyType()) %></b>
                    </div>

                    <div class="offer-row">
                        <span>Fuel</span>
                        <b><%= val(car.getFuelTypes()) %></b>
                    </div>

                    <a class="btn btn-primary" href="login.jsp">
                        Check eligibility →
                    </a>

                    <p>Sign in to get personalised offers from nearby dealers.</p>

                </section>


                <!-- Compare nudge -->

                <section class="side-card">
                    <b>Want to compare?</b>
                    <p>Add the <%= fullName %> to your comparison list.</p>
                    <a href="compare.jsp">Compare cars →</a>
                </section>


                <!-- Source link (when available) -->

                <% if (car.getSourceUrl() != null && !car.getSourceUrl().trim().isEmpty()) { %>

                <section class="side-card" style="margin-top:12px;">
                    <b>More information</b>
                    <p>Read the full specification sheet for this model.</p>
                    <a href="<%= car.getSourceUrl() %>"
                       target="_blank"
                       rel="noopener noreferrer">
                        View source →
                    </a>
                </section>

                <% } %>


            </aside>

        </div>

    </div>
</main>

<% } %>


<!-- =========================================================
     FOOTER
     ========================================================= -->

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

<div class="toast"></div>

<script src="assets/js/carverse.js"></script>

<!-- =========================================================
     GALLERY SWITCHER
     ========================================================= -->

<script>
(function () {

    var mainImage = document.getElementById("main-car-image");
    var thumbsContainer = document.getElementById("gallery-thumbs");

    if (!mainImage || !thumbsContainer) return;

    thumbsContainer.addEventListener("click", function (e) {

        var btn = e.target.closest("button[data-src]");

        if (!btn) return;

        /* Swap primary image */
        mainImage.src = btn.dataset.src;

        /* Update selected state */
        thumbsContainer
            .querySelectorAll("button")
            .forEach(function (b) { b.classList.remove("selected"); });

        btn.classList.add("selected");
    });
}());
</script>

</body>
</html>