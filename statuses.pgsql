-- project_statuses:
-- id, success, url, published_at, project_id, created_at, updated_at, error, build_id, valid_readme
-- 
-- projects:
-- id, guid

SELECT p.guid,
       s.success, s.url, s.published_at, s.updated_at, s.valid_readme
FROM projects AS p
LEFT JOIN project_statuses AS s
ON s.project_id = p.id
ORDER BY updated_at ASC;
