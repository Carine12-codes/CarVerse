<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>CarVerse | Reserve Car</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, Helvetica, sans-serif;
        }


        :root {
            --dark: #171b22;
            --lime: #9bea00;
            --background: #f6f7f5;
            --white: #ffffff;
            --grey: #747980;
            --border: #e2e4e1;
        }


        body {
            background: var(--background);
            color: var(--dark);
        }


        /* ================= NAVBAR ================= */

        .navbar {
            height: 70px;

            background: var(--white);

            display: flex;
            align-items: center;
            justify-content: space-between;

            padding: 0 7%;

            border-bottom: 1px solid var(--border);
        }


        .logo {
            text-decoration: none;

            color: var(--dark);

            font-size: 21px;
            font-weight: 800;

            letter-spacing: 1px;
        }


        .logo span {
            color: #7dbd00;
        }


        .nav-links {
            list-style: none;

            display: flex;
            gap: 30px;
        }


        .nav-links a {
            text-decoration: none;

            color: var(--dark);

            font-size: 11px;
            font-weight: 700;

            text-transform: uppercase;
        }


        .nav-links a:hover {
            color: #7dbd00;
        }


        /* ================= MAIN ================= */

        .container {

            max-width: 1050px;

            margin: auto;

            padding: 65px 25px;
        }


        /* ================= HEADER ================= */

        .page-header {

            margin-bottom: 40px;
        }


        .page-header small {

            color: #7dbd00;

            font-size: 11px;

            font-weight: bold;

            text-transform: uppercase;

            letter-spacing: 1px;
        }


        .page-header h1 {

            margin-top: 8px;

            font-size: 34px;

            text-transform: uppercase;

            letter-spacing: -0.5px;
        }


        .page-header p {

            margin-top: 10px;

            color: var(--grey);

            font-size: 14px;
        }


        /* ================= BOOKING LAYOUT ================= */

        .booking-layout {

            display: grid;

            grid-template-columns: 1fr 1fr;

            gap: 20px;
        }


        /* ================= CAR CARD ================= */

        .car-card {

            background: var(--white);

            border: 1px solid var(--border);

            padding: 35px;
        }


        .card-label {

            color: #7dbd00;

            font-size: 10px;

            font-weight: bold;

            text-transform: uppercase;

            letter-spacing: 1px;

            margin-bottom: 10px;
        }


        .car-card h2 {

            font-size: 26px;

            margin-bottom: 30px;

            text-transform: uppercase;
        }


        .car-details {

            border-top: 1px solid var(--border);
        }


        .detail {

            display: flex;

            justify-content: space-between;

            padding: 17px 0;

            border-bottom: 1px solid var(--border);

            gap: 20px;
        }


        .detail-label {

            color: var(--grey);

            font-size: 11px;

            font-weight: bold;

            text-transform: uppercase;
        }


        .detail-value {

            font-size: 13px;

            font-weight: 600;

            text-align: right;
        }


        /* ================= FORM CARD ================= */

        .form-card {

            background: var(--dark);

            padding: 35px;

            color: white;
        }


        .form-card small {

            color: var(--lime);

            font-size: 10px;

            font-weight: bold;

            text-transform: uppercase;

            letter-spacing: 1px;
        }


        .form-card h2 {

            margin-top: 10px;

            font-size: 26px;

            text-transform: uppercase;
        }


        .form-card p {

            margin-top: 10px;

            margin-bottom: 30px;

            color: #aeb3b9;

            font-size: 13px;

            line-height: 1.6;
        }


        /* ================= FORM ================= */

        label {

            display: block;

            margin-bottom: 9px;

            font-size: 11px;

            font-weight: bold;

            text-transform: uppercase;

            color: #ffffff;
        }


        input {

            width: 100%;

            padding: 15px;

            border: 1px solid #3b4149;

            background: transparent;

            color: white;

            font-size: 14px;

            outline: none;
        }


        input:focus {

            border-color: var(--lime);
        }


        input::placeholder {

            color: #747a81;
        }


        .confirm-btn {

            width: 100%;

            margin-top: 22px;

            padding: 15px;

            background: var(--lime);

            color: var(--dark);

            border: none;

            font-size: 11px;

            font-weight: bold;

            text-transform: uppercase;

            cursor: pointer;

            transition: 0.2s;
        }


        .confirm-btn:hover {

            background: #b4ff19;
        }


        /* ================= FOOTER TEXT ================= */

        .bottom-text {

            margin-top: 40px;

            text-align: center;

            color: var(--grey);

            font-size: 11px;
        }


        /* ================= RESPONSIVE ================= */

        @media(max-width: 800px) {

            .booking-layout {
                grid-template-columns: 1fr;
            }

            .nav-links {
                display: none;
            }

        }


        @media(max-width: 500px) {

            .navbar {
                padding: 0 25px;
            }

            .container {
                padding: 45px 20px;
            }

            .page-header h1 {
                font-size: 28px;
            }

            .car-card,
            .form-card {
                padding: 25px;
            }

        }

    </style>

</head>


<body>


<!-- ================= NAVBAR ================= -->

<nav class="navbar">

    <a href="index.jsp" class="logo">
        CAR<span>VERSE</span>
    </a>


    <ul class="nav-links">

        <li>
            <a href="index.jsp">Home</a>
        </li>

        <li>
            <a href="CarListServlet">Cars</a>
        </li>

        <li>
            <a href="Maintenance.jsp">Maintenance</a>
        </li>

        <li>
            <a href="ProfileServlet">Profile</a>
        </li>

    </ul>

</nav>



<!-- ================= MAIN CONTENT ================= -->

<div class="container">


    <!-- PAGE HEADER -->

    <div class="page-header">

        <small>Car Reservation</small>

        <h1>Reserve Your Car</h1>

        <p>
            Review your selected vehicle and confirm your booking location.
        </p>

    </div>



    <!-- BOOKING LAYOUT -->

    <div class="booking-layout">


        <!-- ================= CAR DETAILS ================= -->

        <div class="car-card">


            <div class="card-label">
                Selected Vehicle
            </div>


            <h2>
                ${car.brand} ${car.modelName}
            </h2>


            <div class="car-details">


                <div class="detail">

                    <div class="detail-label">
                        Brand
                    </div>

                    <div class="detail-value">
                        ${car.brand}
                    </div>

                </div>



                <div class="detail">

                    <div class="detail-label">
                        Body Type
                    </div>

                    <div class="detail-value">
                        ${car.bodyType}
                    </div>

                </div>



                <div class="detail">

                    <div class="detail-label">
                        Price
                    </div>

                    <div class="detail-value">
                        ${car.priceRange}
                    </div>

                </div>



                <div class="detail">

                    <div class="detail-label">
                        Dimensions
                    </div>

                    <div class="detail-value">
                        ${car.length} × ${car.width} × ${car.height} mm
                    </div>

                </div>


            </div>


        </div>



        <!-- ================= BOOKING FORM ================= -->

        <div class="form-card">


            <small>
                Complete Booking
            </small>


            <h2>
                Confirm Reservation
            </h2>


            <p>
                Enter your preferred delivery location to submit your booking.
            </p>


            <form action="BookingSubmitServlet" method="post">


                <!-- CAR ID FROM SERVER -->

                <input
                    type="hidden"
                    name="carId"
                    value="${car.carId}"
                >


                <!-- DROP LOCATION -->

                <label for="dropLocation">
                    Drop Location
                </label>


                <input
                    type="text"
                    id="dropLocation"
                    name="dropLocation"
                    placeholder="Enter your delivery location"
                    required
                >


                <!-- SUBMIT BUTTON -->

                <button
                    type="submit"
                    class="confirm-btn"
                >
                    Confirm Booking →
                </button>


            </form>


        </div>


    </div>



    <!-- BOTTOM TEXT -->

    <div class="bottom-text">

        CarVerse • Find Your Drive

    </div>


</div>


</body>
</html>