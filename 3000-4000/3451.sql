-- Write your PostgreSQL query statement below

with recursive ip_separated_blocks as
(
    SELECT
    log_id,
    ip,
    case when POSITION('.' IN ip) = 0 then ip else SUBSTRING(ip, 1, POSITION('.' IN ip) - 1) end AS ip_block,
    case when POSITION('.' IN ip) = 0 then NULL else SUBSTRING(ip, POSITION('.' IN ip) + 1, 1000) end as ip_remaining,
    1 AS ip_level
    from logs
    UNION ALL
    SELECT
    log_id,
    ip,
    case when POSITION('.' IN ip_remaining) = 0 then ip_remaining else SUBSTRING(ip_remaining, 1, POSITION('.' IN ip_remaining)- 1) end AS ip_block,
    case when POSITION('.' IN ip_remaining) = 0 then NULL else SUBSTRING(ip_remaining, POSITION('.' IN ip_remaining) + 1, 1000) end as ip_remaining,
    ip_level + 1
    from ip_separated_blocks
    WHERE ip_remaining is not NULL
),
ip_validation_tmp as (
    select log_id, ip, ip_block, ip_remaining, ip_level,
    max(ip_level) over (partition by log_id) as max_ip_level,
    sum(case when substrING(IP_BLOCK, 1, 1) = '0' then 1
    when IP_BLOCK::int > 255 then 1
    else 0 end) as valid_block_check
    from ip_separated_blocks
    group by log_id, ip, ip_block, ip_remaining, ip_level
),
ip_validation as (
    select distinct log_id, ip from
    ip_validation_tmp
    where (max_ip_level <> 4
    or valid_block_check > 0)
)
select ip, count(*) as invalid_count
from ip_validation
group by ip
order by 2 desc, 1 desc
