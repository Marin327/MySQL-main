-- 01. Find Book Titles
SELECT `title`
FROM `books`
WHERE substr(`title`, 1,3) = 'The';

-- 02. Replace Titles
SELECT REPLACE(`title`,'The', '***')
FROM `books`
WHERE substr(`title`, 1,3) = 'The'
ORDER BY `id` ASC;

-- 03. Sum Cost of All Books