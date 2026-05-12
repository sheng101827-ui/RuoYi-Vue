package com.ruoyi.system.task;

import java.util.Calendar;
import java.util.Date;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.system.service.ISysOperLogService;

/**
 * 清理操作日志定时任务
 * 
 * @author ruoyi
 */
@Component("cleanOperLogTask")
public class CleanOperLogTask
{
    private static final Logger log = LoggerFactory.getLogger(CleanOperLogTask.class);

    @Autowired
    private ISysOperLogService operLogService;

    /**
     * 清理多少天之前的操作日志
     * 
     * @param days 天数，如 30 表示清理 30 天之前的日志
     */
    public void clean(int days)
    {
        if (days < 0)
        {
            log.error("清理操作日志天数不能小于0：{}", days);
            return;
        }
        
        log.info("开始清理{}天之前的系统操作日志...", days);
        
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DAY_OF_MONTH, -days);
        Date time = calendar.getTime();
        
        try
        {
            int rows = operLogService.deleteOperLogByTime(time);
            log.info("清理系统操作日志结束，共删除 {} 条过期日志数据。", rows);
        }
        catch (Exception e)
        {
            log.error("清理系统操作日志失败", e);
        }
    }
    
    /**
     * 默认清理30天之前的操作日志
     */
    public void cleanDefault()
    {
        clean(30);
    }
}
