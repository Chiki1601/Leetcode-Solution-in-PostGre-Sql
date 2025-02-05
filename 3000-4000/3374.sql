-- Write your PostgreSQL query statement below

WITH RECURSIVE content_sep_words AS (
    SELECT
        content_id,
        content_text,
        '' as delim,
        case when POSITION(' ' IN content_text) = 0 and POSITION('-' IN content_text) = 0 then content_text
        when POSITION(' ' IN content_text) <> 0 and POSITION('-' IN content_text) <> 0 and POSITION(' ' IN content_text) < POSITION('-' IN content_text) then substring(content_text, 1, POSITION(' ' IN content_text) - 1)
        when POSITION(' ' IN content_text) <> 0 and POSITION('-' IN content_text) <> 0 and POSITION('-' IN content_text) < POSITION(' ' IN content_text) then substring(content_text, 1, POSITION('-' IN content_text) - 1)
        when POSITION(' ' IN content_text) <> 0 and POSITION('-' IN content_text) = 0 then substring(content_text, 1, POSITION(' ' IN content_text) - 1)
        when POSITION(' ' IN content_text) = 0 and POSITION('-' IN content_text) <> 0 then substring(content_text, 1, POSITION('-' IN content_text) - 1)
        end AS word,
        case when POSITION(' ' IN content_text) = 0 and POSITION('-' IN content_text) = 0 then ''
        when POSITION(' ' IN content_text) <> 0 and POSITION('-' IN content_text) <> 0 and POSITION(' ' IN content_text) < POSITION('-' IN content_text) then substring(content_text, POSITION(' ' IN content_text), 1000)
        when POSITION(' ' IN content_text) <> 0 and POSITION('-' IN content_text) <> 0 and POSITION('-' IN content_text) < POSITION(' ' IN content_text) then substring(content_text, POSITION('-' IN content_text), 1000)
        when POSITION(' ' IN content_text) <> 0 and POSITION('-' IN content_text) = 0 then substring(content_text, POSITION(' ' IN content_text), 1000)
        when POSITION(' ' IN content_text) = 0 and POSITION('-' IN content_text) <> 0 then substring(content_text, POSITION('-' IN content_text), 1000)
        end AS remaining,
        1 AS word_level
        from user_content
    UNION ALL
    SELECT 
        content_sep_words.content_id,
        content_sep_words.content_text,
        substr(remaining, 1, 1) as delim,
        case when POSITION(' ' IN substring(remaining, 2, 1000)) = 0 and POSITION('-' IN substring(remaining, 2, 1000)) = 0 then substring(remaining, 2, 1000)
        when POSITION(' ' IN substring(remaining, 2, 1000)) <> 0 and POSITION('-' IN substring(remaining, 2, 1000)) <> 0 and POSITION(' ' IN substring(remaining, 2, 1000)) < POSITION('-' IN substring(remaining, 2, 1000)) then substring(substring(remaining, 2, 1000), 1, POSITION(' ' IN substring(remaining, 2, 1000)) - 1)
        when POSITION(' ' IN substring(remaining, 2, 1000)) <> 0 and POSITION('-' IN substring(remaining, 2, 1000)) <> 0 and POSITION('-' IN substring(remaining, 2, 1000)) < POSITION(' ' IN substring(remaining, 2, 1000)) then substring(substring(remaining, 2, 1000), 1, POSITION('-' IN substring(remaining, 2, 1000)) - 1)
        when POSITION(' ' IN substring(remaining, 2, 1000)) <> 0 and POSITION('-' IN substring(remaining, 2, 1000)) = 0 then substring(substring(remaining, 2, 1000), 1, POSITION(' ' IN substring(remaining, 2, 1000)) - 1)
        when POSITION(' ' IN substring(remaining, 2, 1000)) = 0 and POSITION('-' IN substring(remaining, 2, 1000)) <> 0 then substring(substring(remaining, 2, 1000), 1, POSITION('-' IN substring(remaining, 2, 1000)) - 1)
        end AS word,
        case when POSITION(' ' IN substring(remaining, 2, 1000)) = 0 and POSITION('-' IN substring(remaining, 2, 1000)) = 0 then ''
        when POSITION(' ' IN substring(remaining, 2, 1000)) <> 0 and POSITION('-' IN substring(remaining, 2, 1000)) <> 0 and POSITION(' ' IN substring(remaining, 2, 1000)) < POSITION('-' IN substring(remaining, 2, 1000)) then substring(substring(remaining, 2, 1000), POSITION(' ' IN substring(remaining, 2, 1000)), 1000)
        when POSITION(' ' IN substring(remaining, 2, 1000)) <> 0 and POSITION('-' IN substring(remaining, 2, 1000)) <> 0 and POSITION('-' IN substring(remaining, 2, 1000)) < POSITION(' ' IN substring(remaining, 2, 1000)) then substring(substring(remaining, 2, 1000), POSITION('-' IN substring(remaining, 2, 1000)), 1000)
        when POSITION(' ' IN substring(remaining, 2, 1000)) <> 0 and POSITION('-' IN substring(remaining, 2, 1000)) = 0 then substring(substring(remaining, 2, 1000), POSITION(' ' IN substring(remaining, 2, 1000)), 1000)
        when POSITION(' ' IN substring(remaining, 2, 1000)) = 0 and POSITION('-' IN substring(remaining, 2, 1000)) <> 0 then substring(substring(remaining, 2, 1000), POSITION('-' IN substring(remaining, 2, 1000)), 1000)
        end AS remaining,
        word_level + 1
    FROM content_sep_words
    WHERE remaining <> ''
),
content_sep_words_capitalized as (
    select content_id,
    content_text,
    word_level as word_seq,
    word,
    CONCAT(coalesce(delim, ''), upper(substring(WORD, 1, 1)), lower(substring(WORD, 2, 1000))) as formatted_word
    from content_sep_words
)
select
content_id,
content_text as original_text,
STRING_AGG(formatted_word, '' order by word_seq) as converted_text
from content_sep_words_capitalized
group by 1, 2
order by 1
