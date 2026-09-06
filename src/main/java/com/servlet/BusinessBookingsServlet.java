package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Handles View Bookings + Cancellation operations for the Business Partner module.
 *
 * URL: /BusinessBookings
 *
 * Actions:
 *   GET  (default)         — load bookings list (optional ?status= filter), forward to view-bookings.jsp
 *   POST approveCancellation — approve a customer's cancellation request
 *   POST rejectCancellation  — reject a customer's cancellation request
 *
 * Cancellation handling lives here (not on a separate page) as required.
 * Auth: validates BUSINESS_ID + USER_ROLE == "BUSINESS_PARTNER" from session.
 */
@WebServlet("/BusinessBookings")
public class BusinessBookingsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // -----------------------------------------------------------------------
    // GET — bookings list
    // -----------------------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String businessId = getAuthenticatedBusinessId(req, res);
        if (businessId == null) return;

        String statusFilter = req.getParameter("status"); // may be null → all
        loadAndForward(req, res, businessId, statusFilter);
    }

    // -----------------------------------------------------------------------
    // POST — cancellation approve / reject
    // -----------------------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String businessId = getAuthenticatedBusinessId(req, res);
        if (businessId == null) return;

        String action    = trim(req.getParameter("action"));
        String bookingId = trim(req.getParameter("bookingId"));

        if (blank(bookingId)) {
            req.setAttribute("error", "Booking ID is missing.");
            loadAndForward(req, res, businessId, null);
            return;
        }

        try {
            BusinessDAO dao = new BusinessDAO();
            boolean ok;

            if ("approveCancellation".equals(action)) {
                ok = dao.approveCancellation(bookingId, businessId);
                if (ok) {
                    res.sendRedirect("BusinessBookings?success=Cancellation+approved+for+booking+"
                        + bookingId + ".");
                } else {
                    req.setAttribute("error",
                        "Could not approve cancellation. The request may have already been processed.");
                    loadAndForward(req, res, businessId, null);
                }

            } else if ("rejectCancellation".equals(action)) {
                ok = dao.rejectCancellation(bookingId, businessId);
                if (ok) {
                    res.sendRedirect("BusinessBookings?success=Cancellation+rejected+for+booking+"
                        + bookingId + ".");
                } else {
                    req.setAttribute("error",
                        "Could not reject cancellation. The request may have already been processed.");
                    loadAndForward(req, res, businessId, null);
                }

            } else {
                res.sendRedirect("BusinessBookings");
            }

        } catch (Exception e) {
            req.setAttribute("error", "An error occurred: " + e.getMessage());
            loadAndForward(req, res, businessId, null);
        }
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private void loadAndForward(HttpServletRequest req, HttpServletResponse res,
                                String businessId, String statusFilter)
            throws ServletException, IOException {
        try {
            BusinessDAO dao = new BusinessDAO();
            req.setAttribute("bookings",        dao.getBookingsByBusiness(businessId, statusFilter));
            req.setAttribute("statusFilter",    statusFilter);
            req.setAttribute("pendingCancels",  dao.getPendingCancellationCount(businessId));

            String success = req.getParameter("success");
            if (success != null && !success.isEmpty()) req.setAttribute("success", success);

        } catch (Exception e) {
            req.setAttribute("error", "Failed to load bookings: " + e.getMessage());
        }
        req.getRequestDispatcher("view-bookings.jsp").forward(req, res);
    }

    private String getAuthenticatedBusinessId(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect("business-login.jsp"); return null; }
        String businessId = (String) session.getAttribute("BUSINESS_ID");
        String role       = (String) session.getAttribute("USER_ROLE");
        if (businessId == null || !"BUSINESS_PARTNER".equals(role)) {
            res.sendRedirect("business-login.jsp");
            return null;
        }
        return businessId;
    }

    private String trim(String s)   { return s == null ? "" : s.trim(); }
    private boolean blank(String s) { return s == null || s.trim().isEmpty(); }
}
