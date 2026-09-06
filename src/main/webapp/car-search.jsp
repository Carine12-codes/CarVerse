<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.servlet.CarModel" %>

<%
/*
* Data received from CarSearchServlet
*/
List<CarModel> cars =
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


%>

<html lang="en">

<head>

```
<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Search cars | CarVerse</title>

<link rel="stylesheet"
      href="assets/css/carverse.css">
```

</head>

<body>

<!-- =========================================================
     NAVIGATION
     ========================================================= -->

<nav class="nav">

```
<div class="shell">

    <a class="brand"
       href="index.jsp">
        CARVERSE
    </a>

    <div class="navlinks">

        <a href="index.jsp">
            Explore
        </a>

        <a class="active"
           href="car-search">
            New Cars
        </a>

        <a href="compare.jsp">
            Compare
        </a>

        <a href="index.jsp#ownership">
            Ownership
        </a>

    </div>

    <a href="login.jsp">
        Sign in
    </a>

    <a class="btn btn-primary"
       href="user_registration.html">
        Get started →
    </a>

</div>
```

</nav>

<!-- =========================================================
     MAIN SEARCH PAGE
     ========================================================= -->

<main class="search-page">

```
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

    <section class="search-query"
             aria-label="Search cars">

        <form id="car-search-form"
              class="search-form"
              method="get"
              action="<%= request.getContextPath() %>/car-search">


            <!-- Search query -->

            <label class="search-input">

                <span>⌕</span>

                <input
                    name="query"
                    type="search"
                    value="<%= searchQuery != null ? searchQuery : "" %>"
                    placeholder="Search by brand, model or body type"
                    aria-label="Search by brand, model or body type">

            </label>


            <!-- Budget -->

            <select name="budget"
                    id="top-budget"
                    aria-label="Budget">

                <option value="">
                    Any budget
                </option>

                <option value="Under ₹10 Lakh"
                    <%= "Under ₹10 Lakh".equals(selectedBudget) ? "selected" : "" %>>
                    Under ₹10 Lakh
                </option>

                <option value="₹10 - ₹20 Lakh"
                    <%= "₹10 - ₹20 Lakh".equals(selectedBudget) ? "selected" : "" %>>
                    ₹10 - ₹20 Lakh
                </option>

                <option value="₹20 - ₹35 Lakh"
                    <%= "₹20 - ₹35 Lakh".equals(selectedBudget) ? "selected" : "" %>>
                    ₹20 - ₹35 Lakh
                </option>

                <option value="Above ₹35 Lakh"
                    <%= "Above ₹35 Lakh".equals(selectedBudget) ? "selected" : "" %>>
                    Above ₹35 Lakh
                </option>

            </select>


            <button class="btn btn-primary"
                    type="submit">

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

                <%
                    boolean hasFilters =
                        (searchQuery != null &&
                         !searchQuery.trim().isEmpty())
                        ||
                        selectedBudget != null
                        ||
                        (selectedBodies != null &&
                         selectedBodies.length > 0)
                        ||
                        (selectedFuels != null &&
                         selectedFuels.length > 0);

                    if (hasFilters) {
                %>

                    Showing filtered results

                <%
                    } else {
                %>

                    Showing all cars

                <%
                    }
                %>

            </span>

        </div>


        <!-- Sorting -->

        <label class="sort-control">

            Sort by

            <select id="sort-results">

                <option value="Popularity"
                    <%= "Popularity".equals(selectedSort) ? "selected" : "" %>>
                    Popularity
                </option>

                <option value="Price: Low to High"
                    <%= "Price: Low to High".equals(selectedSort) ? "selected" : "" %>>
                    Price: Low to High
                </option>

                <option value="Price: High to Low"
                    <%= "Price: High to Low".equals(selectedSort) ? "selected" : "" %>>
                    Price: High to Low
                </option>

                <option value="Newest first"
                    <%= "Newest first".equals(selectedSort) ? "selected" : "" %>>
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

        <aside class="filter-panel"
               aria-label="Filter cars">


            <div class="filter-title">

                <strong>
                    Filters
                </strong>

                <button id="clear-filters"
                        type="button">

                    Clear all

                </button>

            </div>


            <!-- =============================================
                 BUDGET
                 ============================================= -->

            <details open>

                <summary>
                    Budget
                </summary>


                <label>

                    <input
                        type="radio"
                        name="budget-filter"
                        value=""
                        <%= selectedBudget == null ||
                            selectedBudget.trim().isEmpty()
                            ? "checked" : "" %>>

                    Any budget

                </label>


                <label>

                    <input
                        type="radio"
                        name="budget-filter"
                        value="Under ₹10 Lakh"
                        <%= "Under ₹10 Lakh".equals(selectedBudget)
                            ? "checked" : "" %>>

                    Under ₹10 Lakh

                </label>


                <label>

                    <input
                        type="radio"
                        name="budget-filter"
                        value="₹10 - ₹20 Lakh"
                        <%= "₹10 - ₹20 Lakh".equals(selectedBudget)
                            ? "checked" : "" %>>

                    ₹10 - ₹20 Lakh

                </label>


                <label>

                    <input
                        type="radio"
                        name="budget-filter"
                        value="₹20 - ₹35 Lakh"
                        <%= "₹20 - ₹35 Lakh".equals(selectedBudget)
                            ? "checked" : "" %>>

                    ₹20 - ₹35 Lakh

                </label>


                <label>

                    <input
                        type="radio"
                        name="budget-filter"
                        value="Above ₹35 Lakh"
                        <%= "Above ₹35 Lakh".equals(selectedBudget)
                            ? "checked" : "" %>>

                    Above ₹35 Lakh

                </label>

            </details>


            <!-- =============================================
                 BODY TYPE
                 ============================================= -->

            <details open>

                <summary>
                    Body type
                </summary>


                <label>

                    <input
                        type="checkbox"
                        name="body"
                        value="SUV"
                        <%
                            if (selectedBodies != null) {
                                for (String body : selectedBodies) {
                                    if ("SUV".equalsIgnoreCase(body)) {
                        %>
                                        checked
                        <%
                                    }
                                }
                            }
                        %>>

                    SUV

                </label>


                <label>

                    <input
                        type="checkbox"
                        name="body"
                        value="Hatchback"
                        <%
                            if (selectedBodies != null) {
                                for (String body : selectedBodies) {
                                    if ("Hatchback".equalsIgnoreCase(body)) {
                        %>
                                        checked
                        <%
                                    }
                                }
                            }
                        %>>

                    Hatchback

                </label>


                <label>

                    <input
                        type="checkbox"
                        name="body"
                        value="Sedan"
                        <%
                            if (selectedBodies != null) {
                                for (String body : selectedBodies) {
                                    if ("Sedan".equalsIgnoreCase(body)) {
                        %>
                                        checked
                        <%
                                    }
                                }
                            }
                        %>>

                    Sedan

                </label>


                <label>

                    <input
                        type="checkbox"
                        name="body"
                        value="MUV"
                        <%
                            if (selectedBodies != null) {
                                for (String body : selectedBodies) {
                                    if ("MUV".equalsIgnoreCase(body)) {
                        %>
                                        checked
                        <%
                                    }
                                }
                            }
                        %>>

                    MUV

                </label>

            </details>


            <!-- =============================================
                 FUEL TYPE
                 ============================================= -->

            <details open>

                <summary>
                    Fuel type
                </summary>


                <label>

                    <input
                        type="checkbox"
                        name="fuel"
                        value="Petrol"
                        <%
                            if (selectedFuels != null) {
                                for (String fuel : selectedFuels) {
                                    if ("Petrol".equalsIgnoreCase(fuel)) {
                        %>
                                        checked
                        <%
                                    }
                                }
                            }
                        %>>

                    Petrol

                </label>


                <label>

                    <input
                        type="checkbox"
                        name="fuel"
                        value="Electric"
                        <%
                            if (selectedFuels != null) {
                                for (String fuel : selectedFuels) {
                                    if ("Electric".equalsIgnoreCase(fuel)) {
                        %>
                                        checked
                        <%
                                    }
                                }
                            }
                        %>>

                    Electric

                </label>


                <label>

                    <input
                        type="checkbox"
                        name="fuel"
                        value="Hybrid"
                        <%
                            if (selectedFuels != null) {
                                for (String fuel : selectedFuels) {
                                    if ("Hybrid".equalsIgnoreCase(fuel)) {
                        %>
                                        checked
                        <%
                                    }
                                }
                            }
                        %>>

                    Hybrid

                </label>

            </details>


        </aside>


        <!-- =================================================
             RESULT AREA
             ================================================= -->

        <section class="result-area"
                 aria-live="polite">


            <!-- =============================================
                 ACTIVE FILTER CHIPS
                 ============================================= -->

            <div class="active-chips">


                <% if (selectedBudget != null &&
                       !selectedBudget.trim().isEmpty()) { %>

                    <button type="button"
                            class="filter-chip"
                            data-filter-type="budget"
                            data-filter-value="<%= selectedBudget %>">

                        <%= selectedBudget %>

                        <span>×</span>

                    </button>

                <% } %>


                <% if (selectedBodies != null) {

                    for (String body : selectedBodies) {
                %>

                    <button type="button"
                            class="filter-chip"
                            data-filter-type="body"
                            data-filter-value="<%= body %>">

                        <%= body %>

                        <span>×</span>

                    </button>

                <%
                    }
                } %>


                <% if (selectedFuels != null) {

                    for (String fuel : selectedFuels) {
                %>

                    <button type="button"
                            class="filter-chip"
                            data-filter-type="fuel"
                            data-filter-value="<%= fuel %>">

                        <%= fuel %>

                        <span>×</span>

                    </button>

                <%
                    }
                } %>

            </div>


            <!-- =============================================
                 RESULT CARDS
                 ============================================= -->

            <div class="search-results"
                 id="search-results">


                <% if (cars != null && !cars.isEmpty()) { %>


                    <% for (CarModel car : cars) {

                        String image =
                            car.getImages();

                        /*
                         * images may contain multiple
                         * comma-separated URLs.
                         */
                        String firstImage =
                            image;

                        if (firstImage != null &&
                            firstImage.contains(",")) {

                            firstImage =
                                firstImage.split(",")[0].trim();
                        }

                        /*
                         * Fallback image
                         */
                        if (firstImage == null ||
                            firstImage.trim().isEmpty()) {

                            firstImage =
                                "assets/images/car-placeholder.jpg";
                        }

                    %>


                    <article class="result-card">


                        <!-- Car image -->

                        <a class="result-image"
                           href="<%= request.getContextPath() %>/car-details?carId=<%= car.getCarId() %>">

                            <img
                                src="<%= firstImage %>"
                                alt="<%= car.getBrand() %> <%= car.getModelName() %>">


                            <span class="image-label">
                                <%= car.getFuelTypes() != null
                                    ? car.getFuelTypes()
                                    : "" %>
                            </span>

                        </a>


                        <!-- Card content -->

                        <div class="result-content">


                            <div class="result-title">

                                <div>

                                    <h2>

                                        <a href="<%= request.getContextPath() %>/car-details?carId=<%= car.getCarId() %>">

                                            <%= car.getBrand() %>
                                            <%= car.getModelName() %>

                                        </a>

                                    </h2>


                                    <p>

                                        <%= car.getBodyType() != null
                                            ? car.getBodyType()
                                            : "" %>

                                    </p>

                                </div>


                                <button
                                    class="heart"
                                    type="button"
                                    aria-label="Save <%= car.getModelName() %>">

                                    ♡

                                </button>

                            </div>


                            <!-- Price -->

                            <div class="card-price">

                                <%= car.getPriceRange() != null
                                    ? car.getPriceRange()
                                    : "Price unavailable" %>

                                <sup>*</sup>

                            </div>


                            <!-- Key specifications only -->

                            <div class="result-specs">


                                <% if (car.getMileage() != null &&
                                       !car.getMileage().trim().isEmpty()) { %>

                                    <span>
                                        <%= car.getMileage() %>
                                    </span>

                                <% } %>


                                <% if (car.getEngine() != null &&
                                       !car.getEngine().trim().isEmpty()) { %>

                                    <span>
                                        <%= car.getEngine() %>
                                    </span>

                                <% } %>


                                <% if (car.getDriveType() != null &&
                                       !car.getDriveType().trim().isEmpty()) { %>

                                    <span>
                                        <%= car.getDriveType() %>
                                    </span>

                                <% } %>

                            </div>


                            <!-- Actions -->

                            <div class="card-actions">

                                <a href="<%= request.getContextPath() %>/car-details?carId=<%= car.getCarId() %>">

                                    View details →

                                </a>


                                <a href="<%= request.getContextPath() %>/car-details?carId=<%= car.getCarId() %>#offers">

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

            <% if (totalPages > 1) { %>

            <nav class="pagination"
                 aria-label="Search results pages">


                <!-- Previous -->

                <% if (currentPage > 1) { %>

                    <button
                        class="page-arrow"
                        type="button"
                        data-page="<%= currentPage - 1 %>"
                        aria-label="Previous page">

                        ←

                    </button>

                <% } else { %>

                    <button
                        class="page-arrow"
                        type="button"
                        disabled
                        aria-label="Previous page">

                        ←

                    </button>

                <% } %>


                <!-- Page numbers -->

                <%
                    int startPage =
                        Math.max(1, currentPage - 2);

                    int endPage =
                        Math.min(totalPages,
                                 currentPage + 2);


                    if (startPage > 1) {
                %>

                    <button
                        class="page"
                        type="button"
                        data-page="1">

                        1

                    </button>

                    <% if (startPage > 2) { %>

                        <span>…</span>

                    <% } %>

                <%
                    }


                    for (int i = startPage;
                         i <= endPage;
                         i++) {
                %>

                    <button
                        class="page <%= i == currentPage ? "active" : "" %>"
                        type="button"
                        data-page="<%= i %>"
                        <%= i == currentPage
                            ? "aria-current=\"page\""
                            : "" %>>

                        <%= i %>

                    </button>

                <%
                    }


                    if (endPage < totalPages) {

                        if (endPage < totalPages - 1) {
                %>

                            <span>…</span>

                <%
                        }
                %>

                        <button
                            class="page"
                            type="button"
                            data-page="<%= totalPages %>">

                            <%= totalPages %>

                        </button>

                <%
                    }
                %>


                <!-- Next -->

                <% if (currentPage < totalPages) { %>

                    <button
                        class="page-arrow"
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
```

</main>

<!-- =========================================================
     FOOTER
     ========================================================= -->

<footer class="footer">

```
<div class="shell">

    <div>

        <a class="brand"
           href="index.jsp">
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
```

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

            /*
             * Prevent the native GET so we can include
             * body/fuel/sort (which live outside the form).
             */

            event.preventDefault();

            /*
             * Sync sidebar budget radio from the top dropdown
             * so submitSearch reads the correct value.
             */

            if (topBudget) {

                document
                    .querySelectorAll(
                        'input[name="budget-filter"]'
                    )
                    .forEach(function (radio) {
                        radio.checked =
                            (radio.value === topBudget.value);
                    });
            }

            submitSearch(1);
        }
    );


    /*
     * ---------------------------------------------------------
     * Top budget dropdown → sync sidebar radio (UI only)
     * ---------------------------------------------------------
     */

    if (topBudget) {

        topBudget.addEventListener(
            "change",
            function () {

                document
                    .querySelectorAll(
                        'input[name="budget-filter"]'
                    )
                    .forEach(function (radio) {
                        radio.checked =
                            (radio.value === topBudget.value);
                    });

            }
        );
    }


    /*
     * ---------------------------------------------------------
     * Sidebar budget radio → sync top dropdown (UI only)
     * ---------------------------------------------------------
     */

    document
        .querySelectorAll(
            'input[name="budget-filter"]'
        )
        .forEach(function (radio) {

            radio.addEventListener(
                "change",
                function () {

                    if (topBudget) {
                        topBudget.value = radio.value;
                    }

                }
            );

        });


    /*
     * Sidebar body/fuel checkboxes and sort dropdown
     * do not auto-submit. Their values are read when
     * the Search button is clicked.
     */


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
                        'input[name="fuel"]'
                    )
                    .forEach(function (checkbox) {

                        checkbox.checked = false;

                    });


                if (topBudget) {
                    topBudget.value = "";
                }


                if (sortSelect) {
                    sortSelect.value = "Popularity";
                }

                /*
                 * Remove active filter chips from the DOM
                 * so the cleared state is visible immediately.
                 */

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

                        if (topBudget) {
                            topBudget.value = "";
                        }

                    }


                    if (type === "body") {

                        document
                            .querySelectorAll(
                                'input[name="body"]'
                            )
                            .forEach(function (input) {

                                if (input.value === value) {
                                    input.checked = false;
                                }

                            });

                    }


                    if (type === "fuel") {

                        document
                            .querySelectorAll(
                                'input[name="fuel"]'
                            )
                            .forEach(function (input) {

                                if (input.value === value) {
                                    input.checked = false;
                                }

                            });

                    }


                    /*
                     * Remove this chip from the DOM.
                     */
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
