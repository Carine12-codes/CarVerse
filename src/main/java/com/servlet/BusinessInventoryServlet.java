package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Handles Manage Inventory operations for the Business Partner module.
 *
 * URL: /BusinessInventory
 *
 * Actions:
 *   GET  (default) — load inventory list + summary, forward to manage-inventory.jsp
 *   POST updateStatus — change a car's status (AVAILABLE / MAINTENANCE / INACTIVE)
 *
 * Auth: validates BUSINESS_ID + USER_ROLE == "BUSINESS_PARTNER" from session.
 */
@WebServlet("/BusinessInventory")
public class BusinessInventoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // -----------------------------------------------------------------------
    // GET — inventory list
    // -----------------------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String businessId = getAuthenticatedBusinessId(req, res);
        if (businessId == null) return;

        loadAndForward(req, res, businessId);
    }

    // -----------------------------------------------------------------------
    // POST — status update
    // -----------------------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String businessId = getAuthenticatedBusinessId(req, res);
        if (businessId == null) return;

        String action = req.getParameter("action");

        if ("updateStatus".equals(action)) {
            String carId    = trim(req.getParameter("carId"));
            String newStatus = trim(req.getParameter("newStatus"));

            if (blank(carId) || blank(newStatus)) {
                req.setAttribute("error", "Car ID and status are required.");
                loadAndForward(req, res, businessId);
                return;
            }

            try {
                BusinessDAO dao = new BusinessDAO();
                boolean updated = dao.updateCarStatus(carId, newStatus, businessId);
                if (updated) {
                    res.sendRedirect("BusinessInventory?success=Status+updated+to+" + newStatus + ".");
                } else {
                    req.setAttribute("error",
                        "Could not update status. Invalid status value or car not found.");
                    loadAndForward(req, res, businessId);
                }
            } catch (Exception e) {
                req.setAttribute("error", "Failed to update status: " + e.getMessage());
                loadAndForward(req, res, businessId);
            }

        } else {
            res.sendRedirect("BusinessInventory");
        }
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private void loadAndForward(HttpServletRequest req, HttpServletResponse res,
                                String businessId)
            throws ServletException, IOException {
        try {
            BusinessDAO dao = new BusinessDAO();
            req.setAttribute("inventoryList",    dao.getInventoryList(businessId));
            req.setAttribute("inventorySummary", dao.getInventorySummary(businessId));

            // Pass any one-time success/error from redirect param
            String success = req.getParameter("success");
            if (success != null && !success.isEmpty()) req.setAttribute("success", success);

        } catch (Exception e) {
            req.setAttribute("error", "Failed to load inventory: " + e.getMessage());
        }
        req.getRequestDispatcher("manage-inventory.jsp").forward(req, res);
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
