//
//  AirportSQL.m
//  CCPSQLite
//
//  Created by Ceair on 17/7/4.
//  Copyright © 2017年 ccp. All rights reserved.
//

#import "AirportSQL.h"
#import <sqlite3.h>

@interface AirportSQL()

@property (nonatomic, assign) sqlite3 *db;

@end

@implementation AirportSQL


- (instancetype)init {
    if (self = [super init]) {
        [self create_table:@"airportList"];
        [self arrFromJson:^(NSArray *arr) {
            [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *group = obj[@"group"];
                NSString *match = obj[@"match"];
                NSString *name = obj[@"label"];
                NSString *code = obj[@"value"];
                if ([match containsString:@"'"]) {
                    NSArray *arr = [match componentsSeparatedByString:@"'"];
                    match = [arr componentsJoinedByString:@"''"];
                }
                if ([group containsString:@"'"]) {
                    NSArray *arr = [group componentsSeparatedByString:@"'"];
                    group = [arr componentsJoinedByString:@"''"];
                }
                if ([name containsString:@"'"]) {
                    NSArray *arr = [name componentsSeparatedByString:@"'"];
                    name = [arr componentsJoinedByString:@"''"];
                }
                NSString *sql_str = [NSString stringWithFormat:@"'%@','%@','%@','%@'",name,code,group,match];
                [self insert_table:sql_str];
            }];
        }];
    }
    return self;
}
/*
 * 打开数据库 若数据库不存在 则直接创建
 * dbPath :数据库存储路径(文件名 eg.@"ccpsql.sqlite")
 */

- (sqlite3 *)create_db:(NSString *)dbPath {
    sqlite3 *db;
    NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *flp = [doc stringByAppendingPathComponent:dbPath];
    const char *cFlp = flp.UTF8String;
    int result = sqlite3_open(cFlp, &db);
    NSAssert(result == SQLITE_OK, @"fail to open db");
    return db;
}

- (sqlite3 *)db {
    if (!_db) {
        _db = [self create_db:@"ccpsql.sqlite"];
    }
    return _db;
}

/*
 * 创建表
 * name : 表名
 */
- (void)create_table:(NSString *)name {
    NSString *sql_str = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,match text not null,airport_name text not null,airport_code text not null default \"\",airport_group text not null)",name];
    const char *sql = sql_str.UTF8String;
    char *error_msg = NULL;
    int result = sqlite3_exec(self.db, sql, NULL, NULL, &error_msg);
    if (result != SQLITE_OK) {
        NSLog(@"%s---%d---%s",__FILE__,__LINE__,error_msg);
    }
}

/*
 * 插入数据
 * table 表名
 * values 需要插入的value值,拼接成字符串,以,隔开 如@"'Jack','16'"
 */
- (void)insert_table:(NSString *)values {
    NSString *sql_str = [NSString stringWithFormat:@"insert into airportList (airport_name,airport_code,airport_group,match) values (%@)",values];
    char *error_msg = NULL;
    int result = sqlite3_exec(self.db, sql_str.UTF8String, NULL, NULL, &error_msg);
    if (result != SQLITE_OK) {
        NSLog(@"%s--%s---%d----%s",sql_str.UTF8String,__FILE__,__LINE__,error_msg);
    }
}


/*
 * 从json中获取数据
 */
- (void)arrFromJson:(void(^)(NSArray *arr))sc {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filep = [[NSBundle mainBundle] pathForResource:@"en_US" ofType:@"geojson"];
        NSData *data = [NSData dataWithContentsOfFile:filep];
        NSArray *scArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *err = [NSString stringWithFormat:@"%s--%d--scArr must over 0",__FILE__,__LINE__];
        NSAssert(scArr.count > 0, err);
        if (sc) {
            sc(scArr);
        }
        
    });
}

@end
