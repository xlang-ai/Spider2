WITH
    rb1 AS (SELECT c.* FROM `mitelman-db.prod.CytoConverted` c
        WHERE c.ChrOrd = 13
            AND c.Start < 48303751
            AND c.End > 48481890
            AND c.Type = 'Loss'),
    tp53 AS (SELECT c.* FROM `mitelman-db.prod.CytoConverted` c
        WHERE c.ChrOrd = 17
            AND c.Start < 7668421
            AND c.End > 7687490
            AND c.Type = 'Loss'),
    atm AS (SELECT c.* FROM `mitelman-db.prod.CytoConverted` c
        WHERE c.ChrOrd = 11
            AND c.Start < 108223067
            AND c.End > 108369102
            AND c.Type = 'Gain')
SELECT DISTINCT a.RefNo,
                a.CaseNo,
                a.InvNo,
                r.ChrOrd,
                r.Start,
                r.End,
                t.ChrOrd,
                t.Start,
                t.End,
                m.ChrOrd,
                m.Start,
                m.End,
                n.KaryShort
FROM (
        (SELECT RefNo, CaseNo, InvNo FROM rb1)
        INTERSECT DISTINCT
        (SELECT RefNo, CaseNo, InvNo FROM tp53)
        INTERSECT DISTINCT
        (SELECT RefNo, CaseNo, InvNo FROM atm)
     ) a
JOIN rb1 r
  ON r.RefNo = a.RefNo
  AND r.CaseNo = a.CaseNo
  AND r.InvNo = a.InvNo
JOIN tp53 t
  ON t.RefNo = a.RefNo
  AND t.CaseNo = a.CaseNo
  AND t.InvNo = a.InvNo
JOIN atm m
  ON m.RefNo = a.RefNo
  AND m.CaseNo = a.CaseNo
  AND m.InvNo = a.InvNo
JOIN `mitelman-db.prod.CytogenInv` n
  ON a.RefNo = n.RefNo
  AND a.CaseNo = n.CaseNo
  AND a.InvNo = n.InvNo
ORDER BY a.RefNo,
        a.CaseNo,
        a.InvNo