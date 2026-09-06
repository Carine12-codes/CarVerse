package com.servlet;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Year;
import java.util.ArrayList;
import java.util.List;

/**
 * Data-access object for the Business Partner module.
 *
 * Covers five database concerns:
 *   1. BUSINESS_PARTNERS  — registration, login, profile (fetch + update)
 *   2. CAR_DETAILS        — manage-cars CRUD + toggle status
 *                           (CAR_DETAILS.COMPANY_ID stores the BUSINESS_ID)
 *   3. CAR_DETAILS (fleet)— inventory status queries
 *   4. BOOKING_DETAILS    — bookings per partner + cancellation handling
 *   5. COMMISSION_CONFIG / BOOKING_DETAILS / PAYMENT_DETAILS — earnings
 *
 * Password security:
 *   16-byte SecureRandom salt → SHA-256(salt + password) → stored as saltHex:hashHex
 */
public class BusinessDAO {

    // -----------------------------------------------------------------------
    // DB connection constants — matches the pattern used across the project
    // -----------------------------------------------------------------------

    private static final String DRIVER  = "oracle.jdbc.driver.OracleDriver";
    private static final String URL     = "jdbc:oracle:thin:@localhost:1521:XE";
    private static final String DB_USER = "CARVERSE";
    private static final String DB_PASS = "manager";

    // -----------------------------------------------------------------------
    // Connection helper
    // -----------------------------------------------------------------------

    private Connection getConnection() throws Exception {
        Class.forName(DRIVER);
        return DriverManager.getConnection(URL, DB_USER, DB_PASS);
    }

    // =======================================================================
    // SECTION 1 — BUSINESS_PARTNERS : auth & registration (existing)
    // =======================================================================

    // -----------------------------------------------------------------------
    // Password hashing  (salt:hash stored in DB)
    // -----------------------------------------------------------------------

    /** Generates a salted SHA-256 hash of the plain-text password. */
    public String hashPassword(String plainPassword) {
        try {
            SecureRandom sr = new SecureRandom();
            byte[] saltBytes = new byte[16];
            sr.nextBytes(saltBytes);
            String saltHex = bytesToHex(saltBytes);
            String hashHex = sha256Hex(saltHex + plainPassword);
            return saltHex + ":" + hashHex;
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }

    /** Verifies a plain-text password against the stored saltHex:hashHex value. */
    public boolean verifyPassword(String plainPassword, String storedHash) {
        try {
            if (storedHash == null || !storedHash.contains(":")) return false;
            String[] parts = storedHash.split(":", 2);
            String actualHash = sha256Hex(parts[0] + plainPassword);
            return actualHash.equals(parts[1]);
        } catch (NoSuchAlgorithmException e) {
            return false;
        }
    }

    private String sha256Hex(String input) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] digest = md.digest(input.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        return bytesToHex(digest);
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    // -----------------------------------------------------------------------
    // ID generation — follows the timestamp pattern used by the project
    // -----------------------------------------------------------------------

    public String generateBusinessId() {
        return "bp_" + Year.now().getValue() + "_" + System.currentTimeMillis();
    }

    /** Generates a CAR_DETAILS primary key for business partner cars. */
    public String generateCarId() {
        return "cd_bp_" + Year.now().getValue() + "_" + System.currentTimeMillis();
    }

    // -----------------------------------------------------------------------
    // Registration
    // -----------------------------------------------------------------------

    /**
     * Inserts a new BUSINESS_PARTNERS row.
     * @return  The generated businessId.
     * @throws  DuplicateEmailException if login email already exists.
     */
    public String register(Business b) throws DuplicateEmailException, Exception {

        String id = generateBusinessId();

        String sql =
            "INSERT INTO BUSINESS_PARTNERS (" +
            "  BUSINESS_ID, BUSINESS_NAME, BRAND_NAME, REGISTRATION_NO," +
            "  GSTIN, PAN, BUSINESS_EMAIL, BUSINESS_PHONE, WEBSITE," +
            "  ADDRESS, CITY, STATE, PIN_CODE," +
            "  CONTACT_PERSON_NAME, CONTACT_PERSON_DESIGNATION," +
            "  CONTACT_PERSON_EMAIL, CONTACT_PERSON_PHONE," +
            "  LOGIN_EMAIL, PASSWORD_HASH, ACCOUNT_STATUS," +
            "  CREATED_AT, UPDATED_AT" +
            ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,SYSDATE,SYSDATE)";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1,  id);
            ps.setString(2,  b.getBusinessName());
            ps.setString(3,  b.getBrandName());
            ps.setString(4,  nullIfBlank(b.getRegistrationNo()));
            ps.setString(5,  nullIfBlank(b.getGstin()));
            ps.setString(6,  nullIfBlank(b.getPan()));
            ps.setString(7,  b.getBusinessEmail());
            ps.setString(8,  b.getBusinessPhone());
            ps.setString(9,  nullIfBlank(b.getWebsite()));
            ps.setString(10, b.getAddress());
            ps.setString(11, b.getCity());
            ps.setString(12, b.getState());
            ps.setString(13, b.getPinCode());
            ps.setString(14, b.getContactPersonName());
            ps.setString(15, nullIfBlank(b.getContactPersonDesignation()));
            ps.setString(16, b.getContactPersonEmail());
            ps.setString(17, b.getContactPersonPhone());
            ps.setString(18, b.getLoginEmail());
            ps.setString(19, b.getPasswordHash());
            ps.setString(20, "ACTIVE");
            ps.executeUpdate();
            return id;

        } catch (SQLException e) {
            if (e.getErrorCode() == 1) {
                throw new DuplicateEmailException("An account with this login email already exists.");
            }
            throw e;
        }
    }

    // -----------------------------------------------------------------------
    // Login
    // -----------------------------------------------------------------------

    /**
     * Verifies credentials and returns a populated Business bean on success.
     * @return  Business bean, or null if credentials are wrong.
     * @throws  AccountNotActiveException if the account is not ACTIVE.
     */
    public Business login(String loginEmail, String plainPassword)
            throws AccountNotActiveException, Exception {

        String sql =
            "SELECT BUSINESS_ID, BUSINESS_NAME, BRAND_NAME, PASSWORD_HASH, ACCOUNT_STATUS" +
            "  FROM BUSINESS_PARTNERS WHERE LOGIN_EMAIL = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, loginEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                String storedHash = rs.getString("PASSWORD_HASH");
                String status     = rs.getString("ACCOUNT_STATUS");

                if (!verifyPassword(plainPassword, storedHash)) return null;
                if (!"ACTIVE".equals(status)) throw new AccountNotActiveException(status);

                Business b = new Business();
                b.setBusinessId(rs.getString("BUSINESS_ID"));
                b.setBusinessName(rs.getString("BUSINESS_NAME"));
                b.setBrandName(rs.getString("BRAND_NAME"));
                b.setLoginEmail(loginEmail);
                b.setAccountStatus(status);
                return b;
            }
        }
    }

    // -----------------------------------------------------------------------
    // Duplicate-check helper
    // -----------------------------------------------------------------------

    /** Returns true if a row with this login email already exists. */
    public boolean loginEmailExists(String loginEmail) throws Exception {
        String sql = "SELECT 1 FROM BUSINESS_PARTNERS WHERE LOGIN_EMAIL = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, loginEmail);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    // =======================================================================
    // SECTION 2 — CAR_DETAILS : Manage Cars (CRUD + toggle)
    // Cars are stored in the existing CAR_DETAILS table.
    // CAR_DETAILS.COMPANY_ID holds the business partner's BUSINESS_ID.
    // =======================================================================

    /**
     * Returns all cars belonging to the given business partner, ordered by
     * car_id descending (newest inserts last, reversed).
     */
    public List<BusinessCarBean> getCarsByBusiness(String businessId) throws Exception {
        String sql =
            "SELECT CAR_ID," +
            "       COMPANY_ID AS BUSINESS_ID," +
            "       REGISTRATION_NUMBER, CAR_NAME, BRAND, MODEL," +
            "       MANUFACTURING_YEAR, BODY_TYPE, FUEL_TYPE, TRANSMISSION," +
            "       SEATING_CAPACITY, COLOR, PRICE_PER_DAY, LOCATION," +
            "       AVAILABILITY_STATUS" +
            "  FROM CAR_DETAILS" +
            " WHERE COMPANY_ID = ?" +
            " ORDER BY CAR_ID DESC";

        List<BusinessCarBean> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapCar(rs));
            }
        }
        return list;
    }

    /**
     * Fetches a single car by carId, only if it belongs to the given businessId.
     * Prevents cross-partner data access.
     */
    public BusinessCarBean getCarById(String carId, String businessId) throws Exception {
        String sql =
            "SELECT CAR_ID," +
            "       COMPANY_ID AS BUSINESS_ID," +
            "       REGISTRATION_NUMBER, CAR_NAME, BRAND, MODEL," +
            "       MANUFACTURING_YEAR, BODY_TYPE, FUEL_TYPE, TRANSMISSION," +
            "       SEATING_CAPACITY, COLOR, PRICE_PER_DAY, LOCATION," +
            "       AVAILABILITY_STATUS" +
            "  FROM CAR_DETAILS" +
            " WHERE CAR_ID = ? AND COMPANY_ID = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, carId);
            ps.setString(2, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapCar(rs) : null;
            }
        }
    }

    /**
     * Inserts a new row into CAR_DETAILS for the given business partner.
     * COMPANY_ID is set to the partner's BUSINESS_ID.
     * @return  The generated carId.
     * @throws  DuplicateRegistrationException if REGISTRATION_NUMBER already exists.
     */
    public String addCar(BusinessCarBean c) throws DuplicateRegistrationException, Exception {
        String id = generateCarId();

        String sql =
            "INSERT INTO CAR_DETAILS (" +
            "  CAR_ID, COMPANY_ID, REGISTRATION_NUMBER, CAR_NAME, BRAND, MODEL," +
            "  MANUFACTURING_YEAR, BODY_TYPE, FUEL_TYPE, TRANSMISSION," +
            "  SEATING_CAPACITY, COLOR, PRICE_PER_DAY, LOCATION," +
            "  AVAILABILITY_STATUS" +
            ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,'AVAILABLE')";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1,  id);
            ps.setString(2,  c.getBusinessId());          // COMPANY_ID = BUSINESS_ID
            ps.setString(3,  c.getRegistrationNumber().trim().toUpperCase());
            ps.setString(4,  c.getCarName().trim());
            ps.setString(5,  c.getBrand().trim());
            ps.setString(6,  c.getModel().trim());
            ps.setInt(7,     c.getManufacturingYear());
            ps.setString(8,  nullIfBlank(c.getBodyType()));
            ps.setString(9,  nullIfBlank(c.getFuelType()));
            ps.setString(10, nullIfBlank(c.getTransmission()));
            ps.setInt(11,    c.getSeatingCapacity());
            ps.setString(12, nullIfBlank(c.getColor()));
            ps.setDouble(13, c.getPricePerDay());
            ps.setString(14, nullIfBlank(c.getLocation()));
            ps.executeUpdate();
            return id;

        } catch (SQLException e) {
            if (e.getErrorCode() == 1) {
                throw new DuplicateRegistrationException(
                    "A car with this registration number already exists.");
            }
            throw e;
        }
    }

    /**
     * Updates an existing CAR_DETAILS row's editable fields.
     * COMPANY_ID guard ensures the car belongs to the logged-in partner.
     * @return  true if the row was found and updated.
     */
    public boolean updateCar(BusinessCarBean c, String businessId) throws Exception {
        String sql =
            "UPDATE CAR_DETAILS SET" +
            "  CAR_NAME=?, BRAND=?, MODEL=?, MANUFACTURING_YEAR=?," +
            "  BODY_TYPE=?, FUEL_TYPE=?, TRANSMISSION=?," +
            "  SEATING_CAPACITY=?, COLOR=?, PRICE_PER_DAY=?," +
            "  LOCATION=?" +
            " WHERE CAR_ID=? AND COMPANY_ID=?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1,  c.getCarName().trim());
            ps.setString(2,  c.getBrand().trim());
            ps.setString(3,  c.getModel().trim());
            ps.setInt(4,     c.getManufacturingYear());
            ps.setString(5,  nullIfBlank(c.getBodyType()));
            ps.setString(6,  nullIfBlank(c.getFuelType()));
            ps.setString(7,  nullIfBlank(c.getTransmission()));
            ps.setInt(8,     c.getSeatingCapacity());
            ps.setString(9,  nullIfBlank(c.getColor()));
            ps.setDouble(10, c.getPricePerDay());
            ps.setString(11, nullIfBlank(c.getLocation()));
            ps.setString(12, c.getCarId());
            ps.setString(13, businessId);                 // COMPANY_ID = BUSINESS_ID
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Toggles a car between AVAILABLE and INACTIVE.
     * Cars that are BOOKED or under MAINTENANCE cannot be toggled.
     * @return  The new status string, or null if not found / not toggleable.
     */
    public String toggleCarAvailability(String carId, String businessId) throws Exception {
        String current = null;
        String selectSql =
            "SELECT AVAILABILITY_STATUS FROM CAR_DETAILS" +
            " WHERE CAR_ID=? AND COMPANY_ID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(selectSql)) {
            ps.setString(1, carId);
            ps.setString(2, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) current = rs.getString("AVAILABILITY_STATUS");
            }
        }

        if (current == null) return null;
        if (!"AVAILABLE".equals(current) && !"INACTIVE".equals(current)) return null;

        String newStatus = "AVAILABLE".equals(current) ? "INACTIVE" : "AVAILABLE";

        String updateSql =
            "UPDATE CAR_DETAILS SET AVAILABILITY_STATUS=?" +
            " WHERE CAR_ID=? AND COMPANY_ID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(updateSql)) {
            ps.setString(1, newStatus);
            ps.setString(2, carId);
            ps.setString(3, businessId);
            ps.executeUpdate();
        }
        return newStatus;
    }

    /**
     * Deletes a CAR_DETAILS row only if it has no active bookings and
     * belongs to this partner.
     * @return  true if deleted.
     * @throws  CarHasActiveBookingsException if active bookings exist.
     */
    public boolean deleteCar(String carId, String businessId)
            throws CarHasActiveBookingsException, Exception {

        String checkSql =
            "SELECT COUNT(*) FROM BOOKING_DETAILS" +
            " WHERE CAR_ID = ?" +
            "   AND BOOKING_STATUS NOT IN ('CANCELLED','COMPLETED')";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(checkSql)) {
            ps.setString(1, carId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new CarHasActiveBookingsException(
                        "This car has active bookings and cannot be deleted.");
                }
            }
        }

        String deleteSql =
            "DELETE FROM CAR_DETAILS WHERE CAR_ID=? AND COMPANY_ID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(deleteSql)) {
            ps.setString(1, carId);
            ps.setString(2, businessId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Returns the total number of cars registered by a business partner. */
    public int getCarCount(String businessId) throws Exception {
        String sql = "SELECT COUNT(*) FROM CAR_DETAILS WHERE COMPANY_ID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Returns the number of AVAILABLE cars for a business partner (dashboard stat). */
    public int getActiveCarCount(String businessId) throws Exception {
        String sql =
            "SELECT COUNT(*) FROM CAR_DETAILS" +
            " WHERE COMPANY_ID=? AND AVAILABILITY_STATUS='AVAILABLE'";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // Private mapper — ResultSet row → BusinessCarBean
    // CAR_DETAILS has no CREATED_AT/UPDATED_AT — those fields will be null.
    private BusinessCarBean mapCar(ResultSet rs) throws SQLException {
        BusinessCarBean c = new BusinessCarBean();
        c.setCarId(rs.getString("CAR_ID"));
        c.setBusinessId(rs.getString("BUSINESS_ID")); // aliased from COMPANY_ID
        c.setRegistrationNumber(rs.getString("REGISTRATION_NUMBER"));
        c.setCarName(rs.getString("CAR_NAME"));
        c.setBrand(rs.getString("BRAND"));
        c.setModel(rs.getString("MODEL"));
        c.setManufacturingYear(rs.getInt("MANUFACTURING_YEAR"));
        c.setBodyType(rs.getString("BODY_TYPE"));
        c.setFuelType(rs.getString("FUEL_TYPE"));
        c.setTransmission(rs.getString("TRANSMISSION"));
        c.setSeatingCapacity(rs.getInt("SEATING_CAPACITY"));
        c.setColor(rs.getString("COLOR"));
        c.setPricePerDay(rs.getDouble("PRICE_PER_DAY"));
        c.setLocation(rs.getString("LOCATION"));
        c.setAvailabilityStatus(rs.getString("AVAILABILITY_STATUS"));
        return c;
    }

    // =======================================================================
    // SECTION 3 — CAR_DETAILS (fleet view) : Manage Inventory
    // =======================================================================

    /**
     * Returns inventory summary counts for a business partner's fleet.
     * [0]=AVAILABLE, [1]=BOOKED, [2]=MAINTENANCE, [3]=INACTIVE
     */
    public int[] getInventorySummary(String businessId) throws Exception {
        String sql =
            "SELECT AVAILABILITY_STATUS, COUNT(*) AS CNT" +
            "  FROM CAR_DETAILS" +
            " WHERE COMPANY_ID = ?" +
            " GROUP BY AVAILABILITY_STATUS";

        int[] counts = new int[4];
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("AVAILABILITY_STATUS");
                    int cnt = rs.getInt("CNT");
                    if (status == null) continue;
                    switch (status) {
                        case "AVAILABLE":    counts[0] = cnt; break;
                        case "BOOKED":       counts[1] = cnt; break;
                        case "MAINTENANCE":  counts[2] = cnt; break;
                        case "INACTIVE":     counts[3] = cnt; break;
                    }
                }
            }
        }
        return counts;
    }

    /**
     * Returns the full car list ordered by status priority (BOOKED first,
     * then AVAILABLE, MAINTENANCE, INACTIVE).
     */
    public List<BusinessCarBean> getInventoryList(String businessId) throws Exception {
        String sql =
            "SELECT CAR_ID," +
            "       COMPANY_ID AS BUSINESS_ID," +
            "       REGISTRATION_NUMBER, CAR_NAME, BRAND, MODEL," +
            "       MANUFACTURING_YEAR, BODY_TYPE, FUEL_TYPE, TRANSMISSION," +
            "       SEATING_CAPACITY, COLOR, PRICE_PER_DAY, LOCATION," +
            "       AVAILABILITY_STATUS" +
            "  FROM CAR_DETAILS" +
            " WHERE COMPANY_ID = ?" +
            " ORDER BY" +
            "   CASE AVAILABILITY_STATUS" +
            "     WHEN 'BOOKED'      THEN 1" +
            "     WHEN 'AVAILABLE'   THEN 2" +
            "     WHEN 'MAINTENANCE' THEN 3" +
            "     ELSE 4 END, CAR_NAME";

        List<BusinessCarBean> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapCar(rs));
            }
        }
        return list;
    }

    /**
     * Updates AVAILABILITY_STATUS of a car in CAR_DETAILS.
     * Only AVAILABLE, MAINTENANCE, INACTIVE are allowed — BOOKED is managed
     * by the booking flow and cannot be set manually.
     * @return true if updated.
     */
    public boolean updateCarStatus(String carId, String newStatus, String businessId)
            throws Exception {

        if (!newStatus.equals("AVAILABLE") && !newStatus.equals("MAINTENANCE")
                && !newStatus.equals("INACTIVE")) {
            return false;
        }

        String sql =
            "UPDATE CAR_DETAILS SET AVAILABILITY_STATUS=?" +
            " WHERE CAR_ID=? AND COMPANY_ID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, carId);
            ps.setString(3, businessId);
            return ps.executeUpdate() > 0;
        }
    }

    // =======================================================================
    // SECTION 4 — BOOKING_DETAILS : View Bookings + Cancellation handling
    // =======================================================================

    /**
     * DTO for a booking row joined with customer username and car name.
     * Inner class keeps it co-located with its DAO.
     */
    public static class BookingRecord {
        public String bookingId;
        public String userId;
        public String customerName;   // from USER_REGISTRATION
        public String carId;          // CAR_DETAILS.CAR_ID
        public String carName;        // from CAR_DETAILS
        public String registrationNo; // from CAR_DETAILS
        public String bookingDate;
        public String startDate;
        public String endDate;
        public String pickupLocation;
        public String dropLocation;
        public double totalAmount;
        public String bookingStatus;
        public String paymentStatus;  // from PAYMENT_DETAILS (may be null)
        public String cancellationStatus;
        public String cancellationReason;
        public String cancellationDate;
    }

    /**
     * Returns all bookings for cars owned by the given business partner.
     * Joins CAR_DETAILS on COMPANY_ID = businessId.
     * Optional statusFilter limits by BOOKING_STATUS.
     */
    public List<BookingRecord> getBookingsByBusiness(String businessId,
                                                      String statusFilter) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT b.BOOKING_ID, b.USER_ID," +
            "       NVL(u.USERNAME,'Unknown') AS CUSTOMER_NAME," +
            "       b.CAR_ID, c.CAR_NAME, c.REGISTRATION_NUMBER," +
            "       TO_CHAR(b.BOOKING_DATE,'DD-Mon-YYYY') AS BOOKING_DATE," +
            "       TO_CHAR(b.START_DATE,'DD-Mon-YYYY')   AS START_DATE," +
            "       TO_CHAR(b.END_DATE,'DD-Mon-YYYY')     AS END_DATE," +
            "       b.PICKUP_LOCATION, b.DROP_LOCATION," +
            "       b.TOTAL_AMOUNT, b.BOOKING_STATUS," +
            "       NVL(p.PAYMENT_STATUS,'N/A') AS PAYMENT_STATUS," +
            "       NVL(b.CANCELLATION_STATUS,'NONE') AS CANCELLATION_STATUS," +
            "       b.CANCELLATION_REASON," +
            "       TO_CHAR(b.CANCELLATION_DATE,'DD-Mon-YYYY') AS CANCELLATION_DATE" +
            "  FROM BOOKING_DETAILS b" +
            "  JOIN CAR_DETAILS c ON c.CAR_ID = b.CAR_ID" +
            "  LEFT JOIN USER_REGISTRATION u ON u.USER_ID = b.USER_ID" +
            "  LEFT JOIN PAYMENT_DETAILS   p ON p.BOOKING_ID = b.BOOKING_ID" +
            " WHERE c.COMPANY_ID = ?"
        );

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND b.BOOKING_STATUS = ?");
        }
        sql.append(" ORDER BY b.BOOKING_DATE DESC");

        List<BookingRecord> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            ps.setString(1, businessId);
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(2, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingRecord r = new BookingRecord();
                    r.bookingId          = rs.getString("BOOKING_ID");
                    r.userId             = rs.getString("USER_ID");
                    r.customerName       = rs.getString("CUSTOMER_NAME");
                    r.carId              = rs.getString("CAR_ID");
                    r.carName            = rs.getString("CAR_NAME");
                    r.registrationNo     = rs.getString("REGISTRATION_NUMBER");
                    r.bookingDate        = rs.getString("BOOKING_DATE");
                    r.startDate          = rs.getString("START_DATE");
                    r.endDate            = rs.getString("END_DATE");
                    r.pickupLocation     = rs.getString("PICKUP_LOCATION");
                    r.dropLocation       = rs.getString("DROP_LOCATION");
                    r.totalAmount        = rs.getDouble("TOTAL_AMOUNT");
                    r.bookingStatus      = rs.getString("BOOKING_STATUS");
                    r.paymentStatus      = rs.getString("PAYMENT_STATUS");
                    r.cancellationStatus = rs.getString("CANCELLATION_STATUS");
                    r.cancellationReason = rs.getString("CANCELLATION_REASON");
                    r.cancellationDate   = rs.getString("CANCELLATION_DATE");
                    list.add(r);
                }
            }
        }
        return list;
    }

    /**
     * Approves a cancellation request for a booking.
     * Validates that the booking belongs to this partner before updating.
     * Sets CANCELLATION_STATUS='APPROVED', BOOKING_STATUS='CANCELLED'.
     */
    public boolean approveCancellation(String bookingId, String businessId) throws Exception {
        // Verify the booking belongs to this partner
        if (!bookingBelongsToPartner(bookingId, businessId)) return false;

        String sql =
            "UPDATE BOOKING_DETAILS" +
            "   SET CANCELLATION_STATUS='APPROVED'," +
            "       BOOKING_STATUS='CANCELLED'," +
            "       CANCELLATION_DATE=SYSDATE" +
            " WHERE BOOKING_ID=? AND CANCELLATION_STATUS='REQUESTED'";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Rejects a cancellation request for a booking.
     * Validates ownership, sets CANCELLATION_STATUS='REJECTED'.
     * Booking status remains unchanged (booking continues).
     */
    public boolean rejectCancellation(String bookingId, String businessId) throws Exception {
        if (!bookingBelongsToPartner(bookingId, businessId)) return false;

        String sql =
            "UPDATE BOOKING_DETAILS" +
            "   SET CANCELLATION_STATUS='REJECTED'," +
            "       CANCELLATION_DATE=SYSDATE" +
            " WHERE BOOKING_ID=? AND CANCELLATION_STATUS='REQUESTED'";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Returns the count of pending cancellation requests for this partner.
     * Used by the dashboard stat card.
     */
    public int getPendingCancellationCount(String businessId) throws Exception {
        String sql =
            "SELECT COUNT(*) FROM BOOKING_DETAILS b" +
            "  JOIN CAR_DETAILS c ON c.CAR_ID = b.CAR_ID" +
            " WHERE c.COMPANY_ID=? AND b.CANCELLATION_STATUS='REQUESTED'";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Returns the total booking count for this partner (for dashboard stat). */
    public int getTotalBookingCount(String businessId) throws Exception {
        String sql =
            "SELECT COUNT(*) FROM BOOKING_DETAILS b" +
            "  JOIN CAR_DETAILS c ON c.CAR_ID = b.CAR_ID" +
            " WHERE c.COMPANY_ID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private boolean bookingBelongsToPartner(String bookingId, String businessId)
            throws Exception {
        String sql =
            "SELECT 1 FROM BOOKING_DETAILS b" +
            "  JOIN CAR_DETAILS c ON c.CAR_ID = b.CAR_ID" +
            " WHERE b.BOOKING_ID=? AND c.COMPANY_ID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, bookingId);
            ps.setString(2, businessId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    // =======================================================================
    // SECTION 5 — COMMISSION_DETAILS / PAYMENT_DETAILS : Earnings
    // =======================================================================

    /**
     * DTO that carries the full earnings summary for the earnings page.
     */
    public static class EarningsSummary {
        public int    totalBookings;
        public int    completedBookings;
        public int    pendingBookings;
        public double grossAmount;       // sum of TOTAL_AMOUNT for all bookings
        public double commissionRate;    // e.g. 15.0
        public double commissionAmount;  // platform cut
        public double netEarnings;       // partner's share
        public double completedAmount;   // earnings from COMPLETED bookings
        public double pendingAmount;     // earnings from bookings not yet completed
    }

    /**
     * Fetches an EarningsSummary for the given business partner.
     *
     * Commission rate is read from COMMISSION_CONFIG:
     *   - First checks for a partner-specific rate (PARTNER_ID = businessId).
     *   - Falls back to the default platform rate (PARTNER_ID IS NULL).
     *   - If no config row exists, falls back to 15 %.
     *
     * Gross amount is computed from BOOKING_DETAILS joined to this partner's cars.
     * Commission figures are taken from COMMISSION_DETAILS when available, and
     * calculated on-the-fly otherwise (to handle bookings where commission rows
     * haven't been inserted yet).
     */
    public EarningsSummary getEarningsSummary(String businessId) throws Exception {
        EarningsSummary s = new EarningsSummary();

        // -- 1. Read commission rate from COMMISSION_CONFIG ------------------
        s.commissionRate = getCommissionRate(businessId);

        // -- 2. Aggregate booking totals -------------------------------------
        String bookingSql =
            "SELECT" +
            "  COUNT(*) AS TOTAL_BOOKINGS," +
            "  SUM(CASE WHEN b.BOOKING_STATUS='COMPLETED' THEN 1 ELSE 0 END) AS COMPLETED," +
            "  SUM(CASE WHEN b.BOOKING_STATUS NOT IN ('COMPLETED','CANCELLED') THEN 1 ELSE 0 END) AS PENDING_CNT," +
            "  NVL(SUM(b.TOTAL_AMOUNT),0) AS GROSS," +
            "  NVL(SUM(CASE WHEN b.BOOKING_STATUS='COMPLETED' THEN b.TOTAL_AMOUNT ELSE 0 END),0) AS COMPLETED_AMT," +
            "  NVL(SUM(CASE WHEN b.BOOKING_STATUS NOT IN ('COMPLETED','CANCELLED') THEN b.TOTAL_AMOUNT ELSE 0 END),0) AS PENDING_AMT" +
            "  FROM BOOKING_DETAILS b" +
            "  JOIN CAR_DETAILS c ON c.CAR_ID = b.CAR_ID" +
            " WHERE c.COMPANY_ID = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(bookingSql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    s.totalBookings     = rs.getInt("TOTAL_BOOKINGS");
                    s.completedBookings = rs.getInt("COMPLETED");
                    s.pendingBookings   = rs.getInt("PENDING_CNT");
                    s.grossAmount       = rs.getDouble("GROSS");
                    s.completedAmount   = rs.getDouble("COMPLETED_AMT");
                    s.pendingAmount     = rs.getDouble("PENDING_AMT");
                }
            }
        }

        // -- 3. Try to read commission amounts from COMMISSION_DETAILS -------
        //       If rows exist, use them. Otherwise, calculate from rate.
        String commSql =
            "SELECT NVL(SUM(cd.COMMISSION_AMOUNT),0) AS TOTAL_COMM" +
            "  FROM COMMISSION_DETAILS cd" +
            "  JOIN BOOKING_DETAILS b ON b.BOOKING_ID = cd.BOOKING_ID" +
            "  JOIN CAR_DETAILS c     ON c.CAR_ID = b.CAR_ID" +
            " WHERE c.COMPANY_ID = ? AND cd.COMMISSION_STATUS = 'PAID'";

        double storedCommission = 0;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(commSql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) storedCommission = rs.getDouble("TOTAL_COMM");
            }
        }

        // Use stored commission if it has values; otherwise calculate
        if (storedCommission > 0) {
            s.commissionAmount = storedCommission;
        } else {
            s.commissionAmount = s.grossAmount * (s.commissionRate / 100.0);
        }
        s.netEarnings = s.grossAmount - s.commissionAmount;

        return s;
    }

    /**
     * Returns per-booking earning rows for the earnings detail table.
     * Only COMPLETED and CONFIRMED bookings are shown (not cancelled).
     */
    public List<BookingRecord> getEarningsDetail(String businessId) throws Exception {
        String sql =
            "SELECT b.BOOKING_ID, b.USER_ID," +
            "       NVL(u.USERNAME,'Unknown') AS CUSTOMER_NAME," +
            "       b.CAR_ID, c.CAR_NAME, c.REGISTRATION_NUMBER," +
            "       TO_CHAR(b.BOOKING_DATE,'DD-Mon-YYYY') AS BOOKING_DATE," +
            "       TO_CHAR(b.START_DATE,'DD-Mon-YYYY')   AS START_DATE," +
            "       TO_CHAR(b.END_DATE,'DD-Mon-YYYY')     AS END_DATE," +
            "       b.PICKUP_LOCATION, b.DROP_LOCATION," +
            "       b.TOTAL_AMOUNT, b.BOOKING_STATUS," +
            "       NVL(p.PAYMENT_STATUS,'N/A') AS PAYMENT_STATUS," +
            "       NVL(b.CANCELLATION_STATUS,'NONE') AS CANCELLATION_STATUS," +
            "       b.CANCELLATION_REASON," +
            "       TO_CHAR(b.CANCELLATION_DATE,'DD-Mon-YYYY') AS CANCELLATION_DATE" +
            "  FROM BOOKING_DETAILS b" +
            "  JOIN CAR_DETAILS c ON c.CAR_ID = b.CAR_ID" +
            "  LEFT JOIN USER_REGISTRATION u ON u.USER_ID = b.USER_ID" +
            "  LEFT JOIN PAYMENT_DETAILS   p ON p.BOOKING_ID = b.BOOKING_ID" +
            " WHERE c.COMPANY_ID = ? AND b.BOOKING_STATUS <> 'CANCELLED'" +
            " ORDER BY b.BOOKING_DATE DESC";

        List<BookingRecord> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingRecord r = new BookingRecord();
                    r.bookingId          = rs.getString("BOOKING_ID");
                    r.userId             = rs.getString("USER_ID");
                    r.customerName       = rs.getString("CUSTOMER_NAME");
                    r.carId              = rs.getString("CAR_ID");
                    r.carName            = rs.getString("CAR_NAME");
                    r.registrationNo     = rs.getString("REGISTRATION_NUMBER");
                    r.bookingDate        = rs.getString("BOOKING_DATE");
                    r.startDate          = rs.getString("START_DATE");
                    r.endDate            = rs.getString("END_DATE");
                    r.pickupLocation     = rs.getString("PICKUP_LOCATION");
                    r.dropLocation       = rs.getString("DROP_LOCATION");
                    r.totalAmount        = rs.getDouble("TOTAL_AMOUNT");
                    r.bookingStatus      = rs.getString("BOOKING_STATUS");
                    r.paymentStatus      = rs.getString("PAYMENT_STATUS");
                    r.cancellationStatus = rs.getString("CANCELLATION_STATUS");
                    r.cancellationReason = rs.getString("CANCELLATION_REASON");
                    r.cancellationDate   = rs.getString("CANCELLATION_DATE");
                    list.add(r);
                }
            }
        }
        return list;
    }

    /**
     * Reads the applicable commission rate for a partner from COMMISSION_CONFIG.
     * Partner-specific rate takes precedence over the default (PARTNER_ID IS NULL).
     */
    public double getCommissionRate(String businessId) throws Exception {
        // Partner-specific rate
        String sql =
            "SELECT COMMISSION_RATE FROM COMMISSION_CONFIG" +
            " WHERE (PARTNER_ID=? OR PARTNER_ID IS NULL)" +
            "   AND (EFFECTIVE_TO IS NULL OR EFFECTIVE_TO >= SYSDATE)" +
            " ORDER BY CASE WHEN PARTNER_ID IS NOT NULL THEN 0 ELSE 1 END" +
            " FETCH FIRST 1 ROWS ONLY";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("COMMISSION_RATE");
            }
        }
        return 15.0; // hard-coded fallback if config table is empty
    }

    /** Returns this month's gross booking amount (for dashboard stat). */
    public double getMonthlyRevenue(String businessId) throws Exception {
        String sql =
            "SELECT NVL(SUM(b.TOTAL_AMOUNT),0) AS MONTHLY" +
            "  FROM BOOKING_DETAILS b" +
            "  JOIN CAR_DETAILS c ON c.CAR_ID = b.CAR_ID" +
            " WHERE c.COMPANY_ID=?" +
            "   AND b.BOOKING_STATUS <> 'CANCELLED'" +
            "   AND TRUNC(b.BOOKING_DATE,'MM') = TRUNC(SYSDATE,'MM')";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("MONTHLY") : 0;
            }
        }
    }

    // =======================================================================
    // SECTION 6 — BUSINESS_PARTNERS : Profile (fetch + update)
    // =======================================================================

    /**
     * Fetches the full Business bean for a given businessId.
     * Used by the Business Profile page.
     */
    public Business getProfile(String businessId) throws Exception {
        String sql =
            "SELECT BUSINESS_ID, BUSINESS_NAME, BRAND_NAME, REGISTRATION_NO," +
            "       GSTIN, PAN, BUSINESS_EMAIL, BUSINESS_PHONE, WEBSITE," +
            "       ADDRESS, CITY, STATE, PIN_CODE," +
            "       CONTACT_PERSON_NAME, CONTACT_PERSON_DESIGNATION," +
            "       CONTACT_PERSON_EMAIL, CONTACT_PERSON_PHONE," +
            "       LOGIN_EMAIL, ACCOUNT_STATUS," +
            "       TO_CHAR(CREATED_AT,'DD-Mon-YYYY') AS CREATED_AT," +
            "       TO_CHAR(UPDATED_AT,'DD-Mon-YYYY') AS UPDATED_AT" +
            "  FROM BUSINESS_PARTNERS" +
            " WHERE BUSINESS_ID = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, businessId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Business b = new Business();
                b.setBusinessId(rs.getString("BUSINESS_ID"));
                b.setBusinessName(rs.getString("BUSINESS_NAME"));
                b.setBrandName(rs.getString("BRAND_NAME"));
                b.setRegistrationNo(rs.getString("REGISTRATION_NO"));
                b.setGstin(rs.getString("GSTIN"));
                b.setPan(rs.getString("PAN"));
                b.setBusinessEmail(rs.getString("BUSINESS_EMAIL"));
                b.setBusinessPhone(rs.getString("BUSINESS_PHONE"));
                b.setWebsite(rs.getString("WEBSITE"));
                b.setAddress(rs.getString("ADDRESS"));
                b.setCity(rs.getString("CITY"));
                b.setState(rs.getString("STATE"));
                b.setPinCode(rs.getString("PIN_CODE"));
                b.setContactPersonName(rs.getString("CONTACT_PERSON_NAME"));
                b.setContactPersonDesignation(rs.getString("CONTACT_PERSON_DESIGNATION"));
                b.setContactPersonEmail(rs.getString("CONTACT_PERSON_EMAIL"));
                b.setContactPersonPhone(rs.getString("CONTACT_PERSON_PHONE"));
                b.setLoginEmail(rs.getString("LOGIN_EMAIL"));
                b.setAccountStatus(rs.getString("ACCOUNT_STATUS"));
                b.setCreatedAt(rs.getString("CREATED_AT"));
                b.setUpdatedAt(rs.getString("UPDATED_AT"));
                return b;
            }
        }
    }

    /**
     * Updates the editable fields of a business partner's profile.
     * LOGIN_EMAIL, PASSWORD_HASH, BUSINESS_ID, ACCOUNT_STATUS, CREATED_AT
     * are NOT updatable through this method.
     * @return true if the row was found and updated.
     */
    public boolean updateProfile(Business b) throws Exception {
        String sql =
            "UPDATE BUSINESS_PARTNERS SET" +
            "  BUSINESS_NAME=?, BRAND_NAME=?, REGISTRATION_NO=?," +
            "  GSTIN=?, PAN=?, BUSINESS_EMAIL=?, BUSINESS_PHONE=?, WEBSITE=?," +
            "  ADDRESS=?, CITY=?, STATE=?, PIN_CODE=?," +
            "  CONTACT_PERSON_NAME=?, CONTACT_PERSON_DESIGNATION=?," +
            "  CONTACT_PERSON_EMAIL=?, CONTACT_PERSON_PHONE=?," +
            "  UPDATED_AT=SYSDATE" +
            " WHERE BUSINESS_ID=?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  b.getBusinessName());
            ps.setString(2,  b.getBrandName());
            ps.setString(3,  nullIfBlank(b.getRegistrationNo()));
            ps.setString(4,  nullIfBlank(b.getGstin()));
            ps.setString(5,  nullIfBlank(b.getPan()));
            ps.setString(6,  b.getBusinessEmail());
            ps.setString(7,  b.getBusinessPhone());
            ps.setString(8,  nullIfBlank(b.getWebsite()));
            ps.setString(9,  b.getAddress());
            ps.setString(10, b.getCity());
            ps.setString(11, b.getState());
            ps.setString(12, b.getPinCode());
            ps.setString(13, b.getContactPersonName());
            ps.setString(14, nullIfBlank(b.getContactPersonDesignation()));
            ps.setString(15, b.getContactPersonEmail());
            ps.setString(16, b.getContactPersonPhone());
            ps.setString(17, b.getBusinessId());
            return ps.executeUpdate() > 0;
        }
    }

    // =======================================================================
    // Shared utilities
    // =======================================================================

    /** Converts blank / whitespace-only strings to null for optional fields. */
    private String nullIfBlank(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }

    // =======================================================================
    // Inner exception classes
    // =======================================================================

    /** Thrown when a duplicate login email is detected during registration. */
    public static class DuplicateEmailException extends Exception {
        public DuplicateEmailException(String message) { super(message); }
    }

    /**
     * Thrown when the account exists and the password matches, but the
     * account is not ACTIVE (PENDING / SUSPENDED / REJECTED).
     */
    public static class AccountNotActiveException extends Exception {
        private final String status;
        public AccountNotActiveException(String status) {
            super("Account status: " + status);
            this.status = status;
        }
        public String getStatus() { return status; }
    }

    /** Thrown when attempting to delete a car that has active bookings. */
    public static class CarHasActiveBookingsException extends Exception {
        public CarHasActiveBookingsException(String message) { super(message); }
    }

    /** Thrown when a car with the same registration number already exists. */
    public static class DuplicateRegistrationException extends Exception {
        public DuplicateRegistrationException(String message) { super(message); }
    }
}
