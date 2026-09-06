package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.regex.Pattern;

/**
 * Handles the Business Profile page for the Business Partner module.
 *
 * URL: /BusinessProfile
 *
 * Actions:
 *   GET  (default) — load profile, forward to business-profile.jsp
 *   POST update    — validate + save profile changes, redirect back on success
 *
 * The businessId always comes from the session — never from the request body.
 * LOGIN_EMAIL, PASSWORD_HASH, ACCOUNT_STATUS, and CREATED_AT are not updatable here.
 *
 * Auth: validates BUSINESS_ID + USER_ROLE == "BUSINESS_PARTNER" from session.
 */
@WebServlet("/BusinessProfile")
public class BusinessProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Same patterns used in BusinessRegistrationServlet for consistency
    private static final Pattern EMAIL_RE = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE_RE = Pattern.compile(
        "^(\\+91|0)?[6-9]\\d{9}$");
    private static final Pattern PIN_RE   = Pattern.compile("^\\d{6}$");

    // -----------------------------------------------------------------------
    // GET — load profile
    // -----------------------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String businessId = getAuthenticatedBusinessId(req, res);
        if (businessId == null) return;

        loadAndForward(req, res, businessId);
    }

    // -----------------------------------------------------------------------
    // POST — update profile
    // -----------------------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String businessId = getAuthenticatedBusinessId(req, res);
        if (businessId == null) return;

        // Build updated bean from form
        Business b = buildBeanFromRequest(req, businessId);

        // Validate
        String err = validate(b);
        if (err != null) {
            req.setAttribute("error", err);
            req.setAttribute("profile", b);
            req.getRequestDispatcher("business-profile.jsp").forward(req, res);
            return;
        }

        try {
            BusinessDAO dao = new BusinessDAO();
            boolean updated = dao.updateProfile(b);
            if (updated) {
                // Refresh session business name in case it changed
                HttpSession session = req.getSession(false);
                if (session != null) {
                    session.setAttribute("BUSINESS_NAME", b.getBusinessName());
                    session.setAttribute("BRAND_NAME",    b.getBrandName());
                }
                res.sendRedirect("BusinessProfile?success=Profile+updated+successfully.");
            } else {
                req.setAttribute("error", "No changes were saved. Please try again.");
                req.setAttribute("profile", b);
                req.getRequestDispatcher("business-profile.jsp").forward(req, res);
            }

        } catch (Exception e) {
            req.setAttribute("error", "Failed to update profile: " + e.getMessage());
            req.setAttribute("profile", b);
            req.getRequestDispatcher("business-profile.jsp").forward(req, res);
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
            Business profile = dao.getProfile(businessId);
            if (profile == null) {
                req.setAttribute("error", "Profile not found. Please log in again.");
            } else {
                req.setAttribute("profile", profile);
            }

            String success = req.getParameter("success");
            if (success != null && !success.isEmpty()) req.setAttribute("success", success);

        } catch (Exception e) {
            req.setAttribute("error", "Failed to load profile: " + e.getMessage());
        }
        req.getRequestDispatcher("business-profile.jsp").forward(req, res);
    }

    private Business buildBeanFromRequest(HttpServletRequest req, String businessId) {
        Business b = new Business();
        b.setBusinessId(businessId); // always from session
        b.setBusinessName(trim(req.getParameter("businessName")));
        b.setBrandName(trim(req.getParameter("brandName")));
        b.setRegistrationNo(trim(req.getParameter("registrationNo")));
        b.setGstin(trim(req.getParameter("gstin")));
        b.setPan(trim(req.getParameter("pan")));
        b.setBusinessEmail(trim(req.getParameter("businessEmail")));
        b.setBusinessPhone(trim(req.getParameter("businessPhone")));
        b.setWebsite(trim(req.getParameter("website")));
        b.setAddress(trim(req.getParameter("address")));
        b.setCity(trim(req.getParameter("city")));
        b.setState(trim(req.getParameter("state")));
        b.setPinCode(trim(req.getParameter("pinCode")));
        b.setContactPersonName(trim(req.getParameter("contactPersonName")));
        b.setContactPersonDesignation(trim(req.getParameter("contactPersonDesignation")));
        b.setContactPersonEmail(trim(req.getParameter("contactPersonEmail")));
        b.setContactPersonPhone(trim(req.getParameter("contactPersonPhone")));
        return b;
    }

    private String validate(Business b) {
        if (blank(b.getBusinessName()))        return "Business name is required.";
        if (blank(b.getBrandName()))           return "Brand name is required.";
        if (blank(b.getBusinessEmail())
                || !EMAIL_RE.matcher(b.getBusinessEmail()).matches())
            return "Please enter a valid business email address.";
        if (blank(b.getBusinessPhone())
                || !PHONE_RE.matcher(b.getBusinessPhone()).matches())
            return "Please enter a valid 10-digit business phone number.";
        if (blank(b.getAddress()))             return "Address is required.";
        if (blank(b.getCity()))                return "City is required.";
        if (blank(b.getState()))               return "State is required.";
        if (blank(b.getPinCode())
                || !PIN_RE.matcher(b.getPinCode()).matches())
            return "Please enter a valid 6-digit PIN code.";
        if (blank(b.getContactPersonName()))   return "Contact person name is required.";
        if (blank(b.getContactPersonEmail())
                || !EMAIL_RE.matcher(b.getContactPersonEmail()).matches())
            return "Please enter a valid contact person email address.";
        if (blank(b.getContactPersonPhone())
                || !PHONE_RE.matcher(b.getContactPersonPhone()).matches())
            return "Please enter a valid 10-digit contact person phone number.";
        return null;
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
