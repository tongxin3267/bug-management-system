const router = require('koa-router')();
const jwt = require('jsonwebtoken');

const msSqlDb = require('../databases/msSqlDb');
const tokenSecret = require('../config/tokenSecret');

// 用户登录
router.post('/api/login', async (ctx, next) => {
    let name = ctx.request.body.username || '',
        password = ctx.request.body.password || '';

    let result = await msSqlDb.getLoginData({name});
    const responseBody = {
        status: 0, // 0: 用户不存在，1: 密码错误，2: 同时登录，3: 登录成功
        token: ''
    };
    ctx.body = responseBody;
    if (result.err) {
        responseBody.status = 0;
    } else {
        if (password !== result.userPwd.trim()) {
            console.log(`用户 ${name}: 登录失败`);
            responseBody.status = 1;
        } else {
            const payload = {
                userId: result.userId.toString(),
                userName: result.userName.trim()
            };
            //token签名 有效期为5小时
            const token = jwt.sign(payload, tokenSecret.value, {expiresIn: '5h'});
            await msSqlDb.update({
                params: {
                    userStatus: 3
                },
                tableName: '[dbo].[user]',
                whereSql: `userName = '${name}'`
            });
            console.log(`用户 ${name}: 登录成功`);
            responseBody.status = 3;
            responseBody.token = token;
        }
    }
});

// 用户退出
router.post('/api/exit', async (ctx, next) => {
    console.log(ctx.request.body);
    let result = await msSqlDb.update({
        params: {
            userStatus: 0
        },
        tableName: '[dbo].[user]',
        whereSql: `userId= '${ctx.request.body.userId}'`
    });
    const responseBody = {status: 0};
    if (result.err) responseBody.status = 0;
    else responseBody.status = 1;
    ctx.body = responseBody;
});

// 用户注册
router.post('/api/register', async (ctx, next) => {
    console.log(ctx.request.body);
    const name = ctx.request.body.name || '',
        password = ctx.request.body.pwd || '';

    let result = await msSqlDb.add({
        tableName: '[dbo].[user]',
        params: {
            userName: name,
            userPwd: password,
            userStatus: 3
        }
    });
    console.log(result);
    const responseBody = {
        data: {},
        status: 0, // 0: 注册失败，1: 成功
        token: ''
    };
    ctx.body = responseBody;
    if (result.err) {
        responseBody.status = 0;
    } else {
        result = await msSqlDb.findAll({
            tableName: '[dbo].[user]',
            whereSql: `userName = '${name}'`
        });
        if (result.rows.length === 1) {
            for (let index in result.rows[0]) {
                if (result.rows[0].hasOwnProperty(index) && typeof result.rows[0][index] === 'string') {
                    let str = result.rows[0][index];
                    result.rows[0][index] = str.trim();
                }
            }
            const payload = {
                userId: result.rows[0].userId.toString(),
                userName: result.rows[0].userName
            };
            //token签名 有效期为5小时
            const token = jwt.sign(payload, tokenSecret.value, {expiresIn: '5h'});
            console.log(`用户 ${name}: 注册成功`);
            responseBody.data = result.rows[0];
            responseBody.token = token;
            responseBody.status = 1;
        } else {
            responseBody.status = 0;
        }
    }
});

// 验证身份
router.post('/api/check', async (ctx, next) => {
    const responseBody = {
        status: 0, // 0: 用户不存在，1: 密码错误，2: 同时登录，3: 登录成功
        token: ''
    };
    ctx.body = responseBody;
    const userToken = ctx.request.header.cookie.slice(10);
    console.log(userToken);
    // 验证 payload，获取用户名和 id
    await jwt.verify(userToken, tokenSecret.value, {algorithms: ['HS256']}, (err, decoded) => {
        if (err) {
            if (err.name === 'TokenExpiredError') {
                // 由于 decoded = undefined, 因此使用非验证的 decode() 获取
                const decoded = jwt.decode(userToken);
                const payload = {
                    userId: decoded.userId,
                    userName: decoded.userName
                };
                responseBody.status = 4;
                responseBody.token = jwt.sign(payload, tokenSecret.value, {expiresIn: '5h'});
                console.log('用户身份过期，重新发放');
            } else {
                ctx.response.status = 401;
            }
        } else {
            responseBody.status = 3;
            responseBody.token = userToken;
            console.log('用户身份正常');
        }
    });
});

// 用户名验证
router.post('/api/name/check', async (ctx, next) => {
    console.log(ctx.request.body);
    let name = ctx.request.body.name.toString() || '';
    let result = await msSqlDb.findAll({
        tableName: '[dbo].[user]',
        whereSql: `userName = '${name}'`
    });
    const responseBody = {
        status: 0,
        data: {}
    };
    if (result.rows.length === 0) responseBody.status = 1;
    else {
        responseBody.status = 0;
        for (let index in result.rows[0]) {
            if (result.rows[0].hasOwnProperty(index) && typeof result.rows[0][index] === 'string') {
                let str = result.rows[0][index];
                result.rows[0][index] = str.trim();
            }
        }
        responseBody.data = result.rows[0];
    }
    ctx.body = responseBody;
});

// 获取用户信息
router.post('/api/user/getInfo', async (ctx, next) => {
    let name = ctx.request.body.name.toString() || '';
    let result = await msSqlDb.findAll({
        tableName: '[dbo].[user]',
        whereSql: `userName = '${name}'`
    });
    let responseBody = {status: 0};
    if (result.rows.length === 1) {
        responseBody.status = 1;
        for (let index in result.rows[0]) {
            if (result.rows[0].hasOwnProperty(index) && typeof result.rows[0][index] === 'string') {
                let str = result.rows[0][index];
                result.rows[0][index] = str.trim();
            }
        }
        result.rows[0].userPwd = null;
        responseBody.data = result.rows[0];
    }
    else responseBody.status = 0;
    ctx.body = responseBody;
});

// 修改用户信息
router.post('/api/user/setInfo', async (ctx, next) => {
    let result = await msSqlDb.update({
        params: {
            userName: ctx.request.body.name,
            userDesc: ctx.request.body.desc,
            userEmail: ctx.request.body.email,
            userAvatar: ctx.request.body.avatarId
        },
        tableName: '[dbo].[user]',
        whereSql: `userId = '${ctx.request.body.userId}'`
    });
    let responseBody = {status: 0};
    if (result.err) responseBody.status = 0;
    else responseBody.status = 1;
    ctx.body = responseBody;
});

// 修改用户密码
router.post('/api/user/setSafe', async (ctx, next) => {
    const req = ctx.request.body;
    const result = await msSqlDb.findAll({
        tableName: '[dbo].[user]',
        whereSql: `userId = '${req.userId}'`
    });
    const responseBody = {status: 0};
    if (result.rows[0].userPwd.trim() === req.oldPwd) {
        const data = await msSqlDb.update({
            params: {
                userPwd: req.newPwd,
            },
            tableName: '[dbo].[user]',
            whereSql: `userId = '${req.userId}'`
        });
        if (data.err) responseBody.status = 0;
        else responseBody.status = 1;
    }
    else {
        ctx.body = responseBody;
    }
    ctx.body = responseBody;
});

module.exports = router;
