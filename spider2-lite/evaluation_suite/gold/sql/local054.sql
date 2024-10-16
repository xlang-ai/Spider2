WITH BEST_SELLING_ARTIST AS (
    SELECT 
        ARTISTS.ARTISTID AS ARTIST_ID, 
        ARTISTS.NAME AS ARTIST_NAME,
        SUM(INVOICE_ITEMS.UNITPRICE * INVOICE_ITEMS.QUANTITY) AS TOTAL_SALES
    FROM 
        INVOICE_ITEMS
    JOIN 
        TRACKS ON TRACKS.TRACKID = INVOICE_ITEMS.TRACKID
    JOIN 
        ALBUMS ON ALBUMS.ALBUMID = TRACKS.ALBUMID
    JOIN 
        ARTISTS ON ARTISTS.ARTISTID = ALBUMS.ARTISTID
    GROUP BY 
        ARTISTS.ARTISTID, ARTISTS.NAME
    ORDER BY 
        TOTAL_SALES DESC
    LIMIT 1
),
CUSTOMER_SPENDING AS (
    SELECT
        CUSTOMERS.FIRSTNAME,
        SUM(INVOICE_ITEMS.UNITPRICE * INVOICE_ITEMS.QUANTITY) AS AMOUNT_SPENT
    FROM
        INVOICES
    JOIN
        CUSTOMERS ON CUSTOMERS.CUSTOMERID = INVOICES.CUSTOMERID
    JOIN
        INVOICE_ITEMS ON INVOICE_ITEMS.INVOICEID = INVOICES.INVOICEID
    JOIN
        TRACKS ON TRACKS.TRACKID = INVOICE_ITEMS.TRACKID
    JOIN
        ALBUMS ON ALBUMS.ALBUMID = TRACKS.ALBUMID
    JOIN
        BEST_SELLING_ARTIST ON BEST_SELLING_ARTIST.ARTIST_ID = ALBUMS.ARTISTID
    GROUP BY
        CUSTOMERS.FIRSTNAME
)
SELECT 
    FIRSTNAME,
    AMOUNT_SPENT
FROM 
    CUSTOMER_SPENDING 
WHERE
    AMOUNT_SPENT < 1;