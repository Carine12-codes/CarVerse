package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Handles the Commission & Earnings page for the Business Partner module.
 *
 * URL: /BusinessEarnings
 *
 * Actions:
 *   GET (default) — load earnings summary + detail, forward to earnings.jsp
 *
 * All monetary values are calculated server-side via BusinessDAO.getEarningsSummary().
 * The commission rate is read from COMMISSION_CONFIG (not hardcoded).
 *
 * Auth: validates BUSINESS_ID + USER_ROLE == "BUSINESS_PARTNER" from session.
 */
@WebServlet("/BusinessEarnings")
public class BusinessEarningsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String businessId = getAuthenticatedBusinessId(req, res);
        if (businessId == null) return;

        try {
            BusinessDAO dao = new BusinessDAO();
            req.setAttribute("summary",        dao.getEarningsSummary(businessId));
            req.setAttribute("earningsDetail", dao.getEarningsDetail(businessId));

            String success = req.getParameter("success");
            if (success != null && !success.isEmpty()) req.setAttribute("success", success);

        } catch (Exception e) {
            req.setAttribute("error", "Failed to load earnings: " + e.getMessage());
        }

        req.getRequestDispatcher("earnings.jsp").forward(req, res);
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

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
}
