<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="com.servlet.CarModel" %>

            <% /* * Data received from CarSearchServlet */ List<CarModel> cars =
                (List<CarModel>) request.getAttribute("cars");


                    Integer totalCarsObj =
                    (Integer) request.getAttribute("totalCars");

                    Integer currentPageObj =
                    (Integer) request.getAttribute("currentPage");

                    Integer totalPagesObj =
                    (Integer) request.getAttribute("totalPages");

                    String searchQuery =
                    (String) request.getAttribute("searchQuery");

                    String selectedBudget =
                    (String) request.getAttribute("selectedBudget");

                    String selectedSort =
                    (String) request.getAttribute("selectedSort");

                    int totalCars =
                    totalCarsObj != null ? totalCarsObj : 0;

                    int currentPage =
                    currentPageObj != null ? currentPageObj : 1;

                    int totalPages =
                    totalPagesObj != null ? totalPagesObj : 1;

                    if (selectedSort == null || selectedSort.trim().isEmpty()) {
                    selectedSort = "Popularity";
                    }

                    /*
                    * Current body and fuel filters come directly from
                    * the request because the servlet does not store them
                    * separately as request attributes.
                    */
                    String[] selectedBodies =
                    request.getParameterValues("body");

                    String[] selectedFuels =
                    request.getParameterValues("fuel");

                    String[] selectedBrands = (String[]) request.getAttribute("selectedBrands");
                    if (selectedBrands == null) selectedBrands = request.getParameterValues("brand");

                    String[] selectedTransmissions = (String[]) request.getAttribute("selectedTransmissions");
                    if (selectedTransmissions == null) selectedTransmissions =
                    request.getParameterValues("transmission");

                    String[] selectedSeatings = (String[]) request.getAttribute("selectedSeatings");
                    if (selectedSeatings == null) selectedSeatings = request.getParameterValues("seating");

                    String[] selectedRatings = (String[]) request.getAttribute("selectedRatings");
                    if (selectedRatings == null) selectedRatings = request.getParameterValues("rating");

                    %>

                    <html lang="en">

                    <head>


                        <meta charset="UTF-8">

                        <meta name="viewport" content="width=device-width, initial-scale=1.0">

                        <title>Search cars | CarVerse</title>

                        <link rel="stylesheet" href="assets/css/carverse.css">


                    </head>

                    <body>

                        <!-- =========================================================
     NAVIGATION
     ========================================================= -->

                        <nav class="nav">


                            <div class="shell">

                                <a class="brand" href="index.jsp">
                                    CARVERSE
                                </a>

                                <div class="navlinks">

                                    <a href="index.jsp">
                                        Explore
                                    </a>

                                    <a class="active" href="car-search">
                                        New Cars
                                    </a>

                                    <a href="compare.jsp">
                                        Compare
                                    </a>

                                    <a href="index.jsp#ownership">
                                        Ownership
                                    </a>

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
     MAIN SEARCH PAGE
     ========================================================= -->

                        <main class="search-page">

                            <div class="shell">


                                <!-- Breadcrumbs -->

                                <div class="breadcrumbs">

                                    <a href="index.jsp">
                                        Home
                                    </a>

                                    <span>/</span>

                                    <a href="car-search">
                                        New cars
                                    </a>

                                </div>


                                <!-- =====================================================
         HEADING
         ===================================================== -->

                                <section class="search-heading">

                                    <div>

                                        <div class="eyebrow">
                                            New car discovery
                                        </div>

                                        <h1>
                                            Find a car that feels <em>right.</em>
                                        </h1>

                                        <p>
                                            Explore new cars, compare key essentials
                                            and find the right car for you.
                                        </p>

                                    </div>


                                    <!-- Dynamic result count -->

                                    <div class="search-count">

                                        <strong>
                                            <%= totalCars %>
                                        </strong>

                                        <span>
                                            cars matched
                                        </span>

                                    </div>

                                </section>


                                <!-- =====================================================
         SEARCH BAR
         ===================================================== -->

                                <section class="search-query" aria-label="Search cars">

                                    <form id="car-search-form" class="search-form" method="get"
                                        action="<%= request.getContextPath() %>/car-search">


                                        <!-- Search query -->

                                        <label class="search-input">

                                            <span>⌕</span>

                                            <input name="query" type="search"
                                                value="<%= searchQuery != null ? searchQuery : "" %>"
                                                placeholder="Search by brand, model or body type"
                                                aria-label="Search by brand, model or body type">

                                        </label>




                                        <button class="btn btn-primary" type="submit">

                                            Search cars →

                                        </button>

                                    </form>

                                </section>


                                <!-- =====================================================
         RESULTS TOOLBAR
         ===================================================== -->

                                <div class="results-toolbar">

                                    <div>

                                        <strong>
                                            New cars in India
                                        </strong>

                                        <span id="filter-summary">

                                            <% boolean hasFilters=(searchQuery !=null && !searchQuery.trim().isEmpty())
                                                || (selectedBudget !=null && !selectedBudget.trim().isEmpty()) ||
                                                (selectedBodies !=null && selectedBodies.length> 0)
                                                || (selectedFuels != null && selectedFuels.length > 0)
                                                || (selectedBrands != null && selectedBrands.length > 0)
                                                || (selectedTransmissions != null && selectedTransmissions.length > 0)
                                                || (selectedSeatings != null && selectedSeatings.length > 0)
                                                || (selectedRatings != null && selectedRatings.length > 0);

                                                if (hasFilters) {
                                                %>

                                                Showing filtered results

                                                <% } else { %>

                                                    Showing all cars

                                                    <% } %>

                                        </span>

                                    </div>


                                    <!-- Sorting -->

                                    <label class="sort-control">

                                        Sort by

                                        <select id="sort-results">

                                            <option value="Popularity" <%="Popularity" .equals(selectedSort)
                                                ? "selected" : "" %>>
                                                Popularity
                                            </option>

                                            <option value="Price: Low to High" <%="Price: Low to High"
                                                .equals(selectedSort) ? "selected" : "" %>>
                                                Price: Low to High
                                            </option>

                                            <option value="Price: High to Low" <%="Price: High to Low"
                                                .equals(selectedSort) ? "selected" : "" %>>
                                                Price: High to Low
                                            </option>

                                            <option value="Newest first" <%="Newest first" .equals(selectedSort)
                                                ? "selected" : "" %>>
                                                Newest first
                                            </option>

                                        </select>

                                    </label>

                                </div>


                                <!-- =====================================================
         SEARCH LAYOUT
         ===================================================== -->

                                <div class="search-layout">


                                    <!-- =================================================
             FILTER PANEL
             ================================================= -->

                                    <aside class="filter-panel" aria-label="Filter cars">


                                        <div class="filter-title">

                                            <strong>
                                                Filters
                                            </strong>

                                            <button id="clear-filters" type="button">

                                                Clear all

                                            </button>

                                        </div>


                                        <!-- =============================================
                 BUDGET
                 ============================================= -                                        <% boolean hasSelectedBudget = (selectedBudget != null && !selectedBudget.trim().isEmpty()); %>
                                        <details <%= hasSelectedBudget ? "open" : "" %>>

                                            <summary>
                                                Budget
                                            </summary>


                                            <label>

                                                <input type="radio" name="budget-filter" value=""
                                                    <%=selectedBudget==null || selectedBudget.trim().isEmpty()
                                                    ? "checked" : "" %>>

                                                Any budget

                                            </label>


                                            <label>

                                                <input type="radio" name="budget-filter" value="Under ₹10 Lakh"
                                                    <%="Under ₹10 Lakh" .equals(selectedBudget) ? "checked" : "" %>>

                                                Under ₹10 Lakh

                                            </label>


                                            <label>

                                                <input type="radio" name="budget-filter" value="₹10 - ₹20 Lakh"
                                                    <%="₹10 - ₹20 Lakh" .equals(selectedBudget) ? "checked" : "" %>>

                                                ₹10 - ₹20 Lakh

                                            </label>


                                            <label>

                                                <input type="radio" name="budget-filter" value="₹20 - ₹35 Lakh"
                                                    <%="₹20 - ₹35 Lakh" .equals(selectedBudget) ? "checked" : "" %>>

                                                ₹20 - ₹35 Lakh

                                            </label>


                                            <label>

                                                <input type="radio" name="budget-filter" value="Above ₹35 Lakh"
                                                    <%="Above ₹35 Lakh" .equals(selectedBudget) ? "checked" : "" %>>

                                                Above ₹35 Lakh

                                            </label>

                                        </details>


                                        <!-- =============================================
                  BODY TYPE
                  ============================================= -->

                                        <% boolean hasSelectedBody=(selectedBodies !=null && selectedBodies.length> 0);
                                            %>
                                            <details <%=hasSelectedBody ? "open" : "" %>>

                                                <summary>
                                                    Body type
                                                </summary>


                                                <label>

                                                    <input type="checkbox" name="body" value="SUV" <% if (selectedBodies
                                                        !=null) { for (String body : selectedBodies) { if
                                                        ("SUV".equalsIgnoreCase(body)) { %>
                                                    checked
                                                    <% } } } %>>

                                                        SUV

                                                </label>


                                                <label>

                                                    <input type="checkbox" name="body" value="Hatchback" <% if
                                                        (selectedBodies !=null) { for (String body : selectedBodies) {
                                                        if ("Hatchback".equalsIgnoreCase(body)) { %>
                                                    checked
                                                    <% } } } %>>

                                                        Hatchback

                                                </label>


                                                <label>

                                                    <input type="checkbox" name="body" value="Sedan" <% if
                                                        (selectedBodies !=null) { for (String body : selectedBodies) {
                                                        if ("Sedan".equalsIgnoreCase(body)) { %>
                                                    checked
                                                    <% } } } %>>

                                                        Sedan

                                                </label>


                                                <label>

                                                    <input type="checkbox" name="body" value="MUV" <% if (selectedBodies
                                                        !=null) { for (String body : selectedBodies) { if
                                                        ("MUV".equalsIgnoreCase(body)) { %>
                                                    checked
                                                    <% } } } %>>

                                                        MUV

                                                </label>

                                            </details>


                                            <!-- =============================================
                  FUEL TYPE
                  ============================================= -->

                                            <% boolean hasSelectedFuel=(selectedFuels !=null && selectedFuels.length>
                                                0); %>
                                                <details <%=hasSelectedFuel ? "open" : "" %>>

                                                    <summary>
                                                        Fuel type
                                                    </summary>


                                                    <label>

                                                        <input type="checkbox" name="fuel" value="Petrol" <% if
                                                            (selectedFuels !=null) { for (String fuel : selectedFuels) {
                                                            if ("Petrol".equalsIgnoreCase(fuel)) { %>
                                                        checked
                                                        <% } } } %>>

                                                            Petrol

                                                    </label>


                                                    <label>

                                                        <input type="checkbox" name="fuel" value="Electric" <% if
                                                            (selectedFuels !=null) { for (String fuel : selectedFuels) {
                                                            if ("Electric".equalsIgnoreCase(fuel)) { %>
                                                        checked
                                                        <% } } } %>>

                                                            Electric

                                                    </label>


                                                    <label>

                                                        <input type="checkbox" name="fuel" value="Hybrid" <% if
                                                            (selectedFuels !=null) { for (String fuel : selectedFuels) {
                                                            if ("Hybrid".equalsIgnoreCase(fuel)) { %>
                                                        checked
                                                        <% } } } %>>

                                                            Hybrid

                                                    </label>

                                                </details>


                                                <!-- =============================================
                                                 BRAND
                                                 ============================================= -->

                                                <% boolean hasSelectedBrand=(selectedBrands !=null &&
                                                    selectedBrands.length> 0); %>
                                                    <details <%=hasSelectedBrand ? "open" : "" %>>

                                                        <summary>
                                                            Brand
                                                        </summary>

                                                        <% String[] availableBrands={"Maruti Suzuki", "Hyundai" , "Tata"
                                                            , "Mahindra" , "Toyota" , "Kia" , "BMW" , "Mercedes-Benz" };
                                                            for (String b : availableBrands) { boolean isChecked=false;
                                                            if (selectedBrands !=null) { for (String sb :
                                                            selectedBrands) { if (b.equalsIgnoreCase(sb)) {
                                                            isChecked=true; break; } } } %>
                                                            <label>
                                                                <input type="checkbox" name="brand" value="<%= b %>"
                                                                    <%=isChecked ? "checked" : "" %>>
                                                                <%= b %>
                                                            </label>
                                                            <% } %>

                                                    </details>


                                                    <!-- =============================================
                                                 TRANSMISSION
                                                 ============================================= -->

                                                    <% boolean hasSelectedTransmission=(selectedTransmissions !=null &&
                                                        selectedTransmissions.length> 0); %>
                                                        <details <%=hasSelectedTransmission ? "open" : "" %>>

                                                            <summary>
                                                                Transmission
                                                            </summary>

                                                            <% String[] availableTransmissions={"Automatic", "Manual" };
                                                                for (String t : availableTransmissions) { boolean
                                                                isChecked=false; if (selectedTransmissions !=null) { for
                                                                (String st : selectedTransmissions) { if
                                                                (t.equalsIgnoreCase(st)) { isChecked=true; break; } } }
                                                                %>
                                                                <label>
                                                                    <input type="checkbox" name="transmission"
                                                                        value="<%= t %>" <%=isChecked ? "checked" : ""
                                                                        %>>
                                                                    <%= t %>
                                                                </label>
                                                                <% } %>

                                                        </details>


                                                        <!-- =============================================
                                                 SEATING CAPACITY
                                                 ============================================= -->

                                                        <% boolean hasSelectedSeating=(selectedSeatings !=null &&
                                                            selectedSeatings.length> 0); %>
                                                            <details <%=hasSelectedSeating ? "open" : "" %>>

                                                                <summary>
                                                                    Seating Capacity
                                                                </summary>

                                                                <% String[][] availableSeatings={{"5", "5 Seater" },
                                                                    {"6", "6 Seater" }, {"7", "7 Seater" }}; for
                                                                    (String[] s : availableSeatings) { boolean
                                                                    isChecked=false; if (selectedSeatings !=null) { for
                                                                    (String ss : selectedSeatings) { if
                                                                    (s[0].equalsIgnoreCase(ss)) { isChecked=true; break;
                                                                    } } } %>
                                                                    <label>
                                                                        <input type="checkbox" name="seating"
                                                                            value="<%= s[0] %>" <%=isChecked ? "checked"
                                                                            : "" %>>
                                                                        <%= s[1] %>
                                                                    </label>
                                                                    <% } %>

                                                            </details>


                                                            <!-- =============================================
                                                 SAFETY RATING
                                                 ============================================= -->

                                                            <% boolean hasSelectedRating=(selectedRatings !=null &&
                                                                selectedRatings.length> 0); %>
                                                                <details <%=hasSelectedRating ? "open" : "" %>>

                                                                    <summary>
                                                                        Safety Rating
                                                                    </summary>

                                                                    <% String[][] availableRatings={{"5", "5 Star" },
                                                                        {"4", "4 Star" }, {"3", "3 Star" }}; for
                                                                        (String[] r : availableRatings) { boolean
                                                                        isChecked=false; if (selectedRatings !=null) {
                                                                        for (String sr : selectedRatings) { if
                                                                        (r[0].equalsIgnoreCase(sr)) { isChecked=true;
                                                                        break; } } } %>
                                                                        <label>
                                                                            <input type="checkbox" name="rating"
                                                                                value="<%= r[0] %>" <%=isChecked
                                                                                ? "checked" : "" %>>
                                                                            <%= r[1] %>
                                                                        </label>
                                                                        <% } %>

                                                                </details>


                                    </aside>


                                    <!-- =================================================
             RESULT AREA
             ================================================= -->

                                    <section class="result-area" aria-live="polite">


                                        <!-- =============================================
                 ACTIVE FILTER CHIPS
                 ============================================= -->

                                        <div class="active-chips">


                                            <% if (selectedBudget !=null && !selectedBudget.trim().isEmpty()) { %>

                                                <button type="button" class="filter-chip" data-filter-type="budget"
                                                    data-filter-value="<%= selectedBudget %>">

                                                    <%= selectedBudget %>

                                                        <span>×</span>

                                                </button>

                                                <% } %>


                                                    <% if (selectedBodies !=null) { for (String body : selectedBodies) {
                                                        %>

                                                        <button type="button" class="filter-chip"
                                                            data-filter-type="body" data-filter-value="<%= body %>">

                                                            <%= body %>

                                                                <span>×</span>

                                                        </button>

                                                        <% } } %>


                                                            <% if (selectedFuels !=null) { for (String fuel :
                                                                selectedFuels) { %>

                                                                <button type="button" class="filter-chip"
                                                                    data-filter-type="fuel"
                                                                    data-filter-value="<%= fuel %>">

                                                                    <%= fuel %>

                                                                        <span>×</span>

                                                                </button>

                                                                <% } } %>

                                                                    <% if (selectedBrands !=null) { for (String b :
                                                                        selectedBrands) { %>
                                                                        <button type="button" class="filter-chip"
                                                                            data-filter-type="brand"
                                                                            data-filter-value="<%= b %>">
                                                                            <%= b %> <span>×</span>
                                                                        </button>
                                                                        <% } } %>


                                                                            <% if (selectedTransmissions !=null) { for
                                                                                (String t : selectedTransmissions) { %>
                                                                                <button type="button"
                                                                                    class="filter-chip"
                                                                                    data-filter-type="transmission"
                                                                                    data-filter-value="<%= t %>">
                                                                                    <%= t %> <span>×</span>
                                                                                </button>
                                                                                <% } } %>


                                                                                    <% if (selectedSeatings !=null) {
                                                                                        for (String s :
                                                                                        selectedSeatings) { %>
                                                                                        <button type="button"
                                                                                            class="filter-chip"
                                                                                            data-filter-type="seating"
                                                                                            data-filter-value="<%= s %>">
                                                                                            <%= s %> Seater
                                                                                                <span>×</span>
                                                                                        </button>
                                                                                        <% } } %>


                                                                                            <% if (selectedRatings
                                                                                                !=null) { for (String r
                                                                                                : selectedRatings) { %>
                                                                                                <button type="button"
                                                                                                    class="filter-chip"
                                                                                                    data-filter-type="rating"
                                                                                                    data-filter-value="<%= r %>">
                                                                                                    <%= r %> Star
                                                                                                        <span>×</span>
                                                                                                </button>
                                                                                                <% } } %>

                                        </div>


                                        <!-- =============================================
                 RESULT CARDS
                 ============================================= -->

                                        <div class="search-results" id="search-results">


                                            <% if (cars !=null && !cars.isEmpty()) { %>


                                                <% for (CarModel car : cars) { String image=car.getImages(); /* * images
                                                    may contain multiple * comma-separated URLs. */ String
                                                    firstImage=image; if (firstImage !=null && firstImage.contains(","))
                                                    { firstImage=firstImage.split(",")[0].trim(); } /* * Fallback image
                                                    */ if (firstImage==null || firstImage.trim().isEmpty()) {
                                                    firstImage="assets/images/car-placeholder.jpg" ; } %>


                                                    <article class="result-card">


                                                        <!-- Car image -->

                                                        <a class="result-image"
                                                            href="<%= request.getContextPath() %>/car-details?carId=<%= car.getCarId() %>">

                                                            <img src="<%= firstImage %>"
                                                                alt="<%= car.getBrand() %> <%= car.getModelName() %>">


                                                            <span class="image-label">
                                                                <%= car.getFuelTypes() !=null ? car.getFuelTypes() : ""
                                                                    %>
                                                            </span>

                                                        </a>


                                                        <!-- Card content -->

                                                        <div class="result-content">


                                                            <div class="result-title">

                                                                <div>

                                                                    <h2>

                                                                        <a
                                                                            href="<%= request.getContextPath() %>/car-details?carId=<%= car.getCarId() %>">

                                                                            <%= car.getModelName() %>

                                                                        </a>

                                                                    </h2>


                                                                    <p>

                                                                        <%= car.getBodyType() !=null ? car.getBodyType()
                                                                            : "" %>

                                                                    </p>

                                                                </div>

                                                            </div>


                                                            <!-- Price -->

                                                            <% String displayPrice=car.getPriceRange(); if (displayPrice
                                                                !=null && !displayPrice.trim().isEmpty() &&
                                                                !displayPrice.equalsIgnoreCase("Price unavailable")) {
                                                                displayPrice=displayPrice.trim(); if
                                                                (!displayPrice.startsWith("₹") &&
                                                                !displayPrice.startsWith("Rs")) { displayPrice="₹" +
                                                                displayPrice; } } else {
                                                                displayPrice="Price unavailable" ; } %>

                                                                <div class="card-price">

                                                                    <%= displayPrice %><sup>*</sup>

                                                                </div>


                                                                <!-- Key specifications only -->

                                                                <div class="result-specs">


                                                                    <% if (car.getMileage() !=null &&
                                                                        !car.getMileage().trim().isEmpty()) { %>

                                                                        <span>
                                                                            <%= car.getMileage() %>
                                                                        </span>

                                                                        <% } %>


                                                                            <% if (car.getEngine() !=null &&
                                                                                !car.getEngine().trim().isEmpty()) { %>

                                                                                <span>
                                                                                    <%= car.getEngine() %>
                                                                                </span>

                                                                                <% } %>


                                                                                    <% if (car.getDriveType() !=null &&
                                                                                        !car.getDriveType().trim().isEmpty())
                                                                                        { %>

                                                                                        <span>
                                                                                            <%= car.getDriveType() %>
                                                                                        </span>

                                                                                        <% } %>

                                                                </div>


                                                                <!-- Actions -->

                                                                <div class="card-actions">

                                                                    <a
                                                                        href="<%= request.getContextPath() %>/car-details?carId=<%= car.getCarId() %>">

                                                                        View details →

                                                                    </a>


                                                                    <a
                                                                        href="<%= request.getContextPath() %>/car-details?carId=<%= car.getCarId() %>#offers">

                                                                        Get offers

                                                                    </a>

                                                                </div>


                                                        </div>

                                                    </article>


                                                    <% } %>


                                                        <% } else { %>


                                                            <!-- No results -->

                                                            <div class="no-results">

                                                                <h2>
                                                                    No cars found
                                                                </h2>

                                                                <p>
                                                                    Try changing your search or filters.
                                                                </p>

                                                            </div>


                                                            <% } %>


                                        </div>


                                        <!-- =================================================
                 PAGINATION
                 ================================================= -->

                                        <% if (totalPages> 1) { %>

                                            <nav class="pagination" aria-label="Search results pages">


                                                <!-- Previous -->

                                                <% if (currentPage> 1) { %>

                                                    <button class="page-arrow" type="button"
                                                        data-page="<%= currentPage - 1 %>" aria-label="Previous page">

                                                        ←

                                                    </button>

                                                    <% } else { %>

                                                        <button class="page-arrow" type="button" disabled
                                                            aria-label="Previous page">

                                                            ←

                                                        </button>

                                                        <% } %>


                                                            <!-- Page numbers -->

                                                            <% int startPage=Math.max(1, currentPage - 2); int
                                                                endPage=Math.min(totalPages, currentPage + 2); if
                                                                (startPage> 1) {
                                                                %>

                                                                <button class="page" type="button" data-page="1">

                                                                    1

                                                                </button>

                                                                <% if (startPage> 2) { %>

                                                                    <span>…</span>

                                                                    <% } %>

                                                                        <% } for (int i=startPage; i <=endPage; i++) {
                                                                            %>

                                                                            <button
                                                                                class="page <%= (i == currentPage) ? "active" : "" %>"
                                                                                type="button"
                                                                                data-page="<%= i %>"
                                                                                    <%= (i==currentPage) ? "aria-current=\"page\"" : "" %>>

                                                                                        <%= i %>

                                                                            </button>

                                                                            <% } if (endPage < totalPages) { if (endPage
                                                                                < totalPages - 1) { %>

                                                                                <span>…</span>

                                                                                <% } %>

                                                                                    <button class="page" type="button"
                                                                                        data-page="<%= totalPages %>">

                                                                                        <%= totalPages %>

                                                                                    </button>

                                                                                    <% } %>


                                                                                        <!-- Next -->

                                                                                        <% if (currentPage < totalPages)
                                                                                            { %>

                                                                                            <button class="page-arrow"
                                                                                                type="button"
                                                                                                data-page="<%= currentPage + 1 %>"
                                                                                                aria-label="Next page">

                                                                                                →

                                                                                            </button>

                                                                                            <% } else { %>

                                                                                                <button
                                                                                                    class="page-arrow"
                                                                                                    type="button"
                                                                                                    disabled
                                                                                                    aria-label="Next page">

                                                                                                    →

                                                                                                </button>

                                                                                                <% } %>


                                            </nav>

                                            <% } %>


                                    </section>

                                </div>

                            </div>

                        </main>

                        <!-- =========================================================
     FOOTER
     ========================================================= -->

                        <footer class="footer">

                            <div class="shell">

                                <div>

                                    <a class="brand" href="index.jsp">
                                        CARVERSE
                                    </a>

                                    <p>
                                        Drive your next decision with confidence.
                                    </p>

                                </div>

                                <div>
                                    Explore · Compare · Book · Maintenance · Support
                                </div>

                                <div>
                                    © 2026 CarVerse
                                </div>

                            </div>

                        </footer>

                        <!-- =========================================================
     JAVASCRIPT
     ========================================================= -->

                        <script>

                            document.addEventListener("DOMContentLoaded", function () {


                                const searchForm =
                                    document.getElementById("car-search-form");

                                const sortSelect =
                                    document.getElementById("sort-results");

                                const clearButton =
                                    document.getElementById("clear-filters");

                                const topBudget =
                                    document.getElementById("top-budget");


                                /*
                                 * ---------------------------------------------------------
                                 * Build URL from current search/filter state
                                 * ---------------------------------------------------------
                                 */

                                function submitSearch(page) {

                                    const params =
                                        new URLSearchParams();


                                    /*
                                     * Search text
                                     */

                                    const queryInput =
                                        searchForm.querySelector(
                                            'input[name="query"]'
                                        );

                                    if (queryInput &&
                                        queryInput.value.trim() !== "") {

                                        params.append(
                                            "query",
                                            queryInput.value.trim()
                                        );
                                    }


                                    /*
                                     * Budget
                                     *
                                     * The sidebar and top dropdown represent
                                     * the same budget filter.
                                     */

                                    const selectedBudget =
                                        document.querySelector(
                                            'input[name="budget-filter"]:checked'
                                        );

                                    let budgetValue = "";


                                    if (selectedBudget) {

                                        budgetValue =
                                            selectedBudget.value;

                                    } else if (topBudget) {

                                        budgetValue =
                                            topBudget.value;
                                    }


                                    if (budgetValue !== "") {

                                        params.append(
                                            "budget",
                                            budgetValue
                                        );
                                    }


                                    /*
                                     * Body types
                                     */

                                    document
                                        .querySelectorAll(
                                            'input[name="body"]:checked'
                                        )
                                        .forEach(function (checkbox) {

                                            params.append(
                                                "body",
                                                checkbox.value
                                            );

                                        });


                                    /*
                                     * Fuel types
                                     */

                                    document
                                        .querySelectorAll(
                                            'input[name="fuel"]:checked'
                                        )
                                        .forEach(function (checkbox) {

                                            params.append(
                                                "fuel",
                                                checkbox.value
                                            );

                                        });


                                    /*
                                     * Brand
                                     */

                                    document
                                        .querySelectorAll(
                                            'input[name="brand"]:checked'
                                        )
                                        .forEach(function (checkbox) {

                                            params.append(
                                                "brand",
                                                checkbox.value
                                            );

                                        });


                                    /*
                                     * Transmission
                                     */

                                    document
                                        .querySelectorAll(
                                            'input[name="transmission"]:checked'
                                        )
                                        .forEach(function (checkbox) {

                                            params.append(
                                                "transmission",
                                                checkbox.value
                                            );

                                        });


                                    /*
                                     * Seating capacity
                                     */

                                    document
                                        .querySelectorAll(
                                            'input[name="seating"]:checked'
                                        )
                                        .forEach(function (checkbox) {

                                            params.append(
                                                "seating",
                                                checkbox.value
                                            );

                                        });


                                    /*
                                     * Safety rating
                                     */

                                    document
                                        .querySelectorAll(
                                            'input[name="rating"]:checked'
                                        )
                                        .forEach(function (checkbox) {

                                            params.append(
                                                "rating",
                                                checkbox.value
                                            );

                                        });


                                    /*
                                     * Sort
                                     */

                                    if (sortSelect) {

                                        params.append(
                                            "sort",
                                            sortSelect.value
                                        );
                                    }


                                    /*
                                     * Page
                                     */

                                    params.append(
                                        "page",
                                        page
                                    );


                                    /*
                                     * Redirect to servlet
                                     */

                                    window.location.href =
                                        "<%= request.getContextPath() %>/car-search?"
                                        + params.toString();

                                }


                                /*
                                 * ---------------------------------------------------------
                                 * Search form
                                 * ---------------------------------------------------------
                                 */

                                searchForm.addEventListener(
                                    "submit",
                                    function (event) {

                                        event.preventDefault();
                                        submitSearch(1);
                                    }
                                );


                                /*
                                 * ---------------------------------------------------------
                                 * Clear all filters
                                 * ---------------------------------------------------------
                                 */

                                if (clearButton) {

                                    clearButton.addEventListener(
                                        "click",
                                        function () {

                                            const queryInput =
                                                searchForm.querySelector(
                                                    'input[name="query"]'
                                                );

                                            if (queryInput) {
                                                queryInput.value = "";
                                            }


                                            document
                                                .querySelectorAll(
                                                    'input[name="budget-filter"]'
                                                )
                                                .forEach(function (radio) {

                                                    radio.checked = false;

                                                });


                                            document
                                                .querySelectorAll(
                                                    'input[name="body"],' +
                                                    'input[name="fuel"],' +
                                                    'input[name="brand"],' +
                                                    'input[name="transmission"],' +
                                                    'input[name="seating"],' +
                                                    'input[name="rating"]'
                                                )
                                                .forEach(function (checkbox) {

                                                    checkbox.checked = false;

                                                });


                                            if (sortSelect) {
                                                sortSelect.value = "Popularity";
                                            }

                                            document
                                                .querySelectorAll(".filter-chip")
                                                .forEach(function (chip) {
                                                    chip.remove();
                                                });

                                        }
                                    );

                                }


                                /*
                                 * ---------------------------------------------------------
                                 * Active filter chips
                                 * ---------------------------------------------------------
                                 */

                                document
                                    .querySelectorAll(
                                        ".filter-chip"
                                    )
                                    .forEach(function (chip) {

                                        chip.addEventListener(
                                            "click",
                                            function () {

                                                const type =
                                                    chip.dataset.filterType;

                                                const value =
                                                    chip.dataset.filterValue;


                                                if (type === "budget") {

                                                    const budgetRadio =
                                                        document.querySelector(
                                                            'input[name="budget-filter"][value="' +
                                                            CSS.escape(value) +
                                                            '"]'
                                                        );

                                                    if (budgetRadio) {
                                                        budgetRadio.checked = false;
                                                    }

                                                }


                                                if (type === "body" || type === "fuel" || type === "brand" || type === "transmission" || type === "seating" || type === "rating") {

                                                    document
                                                        .querySelectorAll(
                                                            'input[name="' + type + '"]'
                                                        )
                                                        .forEach(function (input) {

                                                            if (input.value === value) {
                                                                input.checked = false;
                                                            }

                                                        });

                                                }


                                                chip.remove();

                                            }
                                        );

                                    });


                                /*
                                 * ---------------------------------------------------------
                                 * Pagination
                                 * ---------------------------------------------------------
                                 */

                                document
                                    .querySelectorAll(
                                        ".pagination [data-page]"
                                    )
                                    .forEach(function (button) {

                                        button.addEventListener(
                                            "click",
                                            function () {

                                                const page =
                                                    parseInt(
                                                        button.dataset.page
                                                    );

                                                submitSearch(page);

                                            }
                                        );

                                    });

                            });

                        </script>

                    </body>

                    </html>