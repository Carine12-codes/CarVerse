<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    String bookingId    = (String) request.getAttribute("bookingId");
    Object totalAmount  = request.getAttribute("totalAmount");
    String dropLocation = (String) request.getAttribute("dropLocation");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Confirmed | CarVerse</title>

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

        .container {
            max-width: 600px;
            margin: auto;
            padding: 90px 25px;
        }

        .confirm-card {
            background: var(--white);
            border: 1px solid var(--border);
            padding: 45px;
            text-align: center;
        }

        .badge {
            display: inline-block;
            background: var(--lime);
            color: var(--dark);
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 6px 14px;
            margin-bottom: 20px;
        }

        h1 {
            font-size: 26px;
            text-transform: uppercase;
            margin-bottom: 12px;
        }

        p {
            color: var(--grey);
            font-size: 14px;
            margin-bottom: 24px;
        }

        .summary {
            border-top: 1px solid var(--border);
            text-align: left;
            margin-top: 10px;
        }

        .row {
            display: flex;
            justify-content: space-between;
            padding: 14px 0;
            border-bottom: 1px solid var(--border);
            font-size: 13px;
        }

        .row span:first-child {
            color: var(--grey);
            font-weight: bold;
            text-transform: uppercase;
            font-size: 11px;
        }

        .btn-primary {
            display: inline-block;
            margin-top: 28px;
            padding: 15px 30px;
            background: var(--lime);
            color: var(--dark);
            text-decoration: none;
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="confirm-card">

        <div class="badge">Pending Confirmation</div>

        <h1>Booking Received</h1>
        <p>We've saved your reservation. Our team will confirm your pickup details shortly.</p>

        <div class="summary">

            <div class="row">
                <span>Booking ID</span>
                <span><%= bookingId != null ? bookingId : "—" %></span>
            </div>

            <div class="row">
                <span>Drop Location</span>
                <span><%= (dropLocation != null && !dropLocation.isEmpty()) ? dropLocation : "—" %></span>
            </div>

            <div class="row">
                <span>Total Amount</span>
                <span><%= totalAmount != null ? "₹" + totalAmount : "—" %></span>
            </div>

            <div class="row">
                <span>Status</span>
                <span>Pending</span>
            </div>

        </div>

        <a class="btn-primary" href="<%= request.getContextPath() %>/index.jsp">
            Back to Home →
        </a>

    </div>
</div>

</body>
</html>