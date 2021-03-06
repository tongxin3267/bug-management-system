<template>
    <div class="padding" :class="{ bordered: isBordered }">
        <slot name="header">
            <div class="header">
                <Icon type="pull-request fa-fw" style="color: #2d8cf0"></Icon>
                项目版本
            </div>
        </slot>
        <div class="content-layout">
            <Card>
                <div class="content-input">
                    <p>新版本号：</p>
                    <Input v-model="tmpVersion.title" clearable
                           style="width: 200px" placeholder="默认起始为：1.0.0"></Input>
                    <p>简要描述：</p>
                    <Input v-model="tmpVersion.desc" type="textarea" :autosize="{minRows: 2,maxRows: 5}"
                           style="width: 360px"></Input>
                </div>
            </Card>
            <Card>
                <Timeline pending class="content-line">
                    <TimelineItem v-for="version in versionList" :key="version.title">
                        <p class="time-line-title">{{version.title}} 版本</p>
                        <p class="time-line-content">{{version.desc}}</p>
                    </TimelineItem>
                    <TimelineItem>
                        <p class="time-line-title">查看更多</p>
                    </TimelineItem>
                </Timeline>
            </Card>
        </div>
        <div class="content-button">
            <ButtonGroup size="large">
                <Button @click="handleReset('tmpVersion')">取消</Button>
                <Button type="primary" @click="handleSubmit('tmpVersion')">确定</Button>
            </ButtonGroup>
        </div>
    </div>
</template>

<script>
    import {mapState} from 'vuex';

    export default {
        name: "ProjectVersions",
        props: {
            isBordered: {
                type: Boolean,
                default: true
            },
            data: {
                type: Object
            }
        },
        data() {
            return {
                versionList: [],
                tmpVersion: {title: '', desc: ''}  //新版本号临时数据
            }
        },
        methods: {
            initData() {
                if (!this.data) {
                    if (this.defaultIndex >= 0) {
                        this.versionList = this.projectList[this.defaultIndex].versionList;
                        // 只显示最近5个版本
                        if (this.versionList.length > 5) {
                            this.versionList = this.versionList.slice(-5);
                        }
                        this.versionList = this.versionList.map(version => Object.assign({}, version))
                            .reverse();
                    } else {
                        // 未设置默认项目
                        this.$router.push({name: 'myProject'});
                        this.$root.Bus.$emit('closeComponent', 'ProjectVersions');
                        this.$Notice.warning({
                            title: '没有项目可打开！',
                            desc: '请设置你的默认项目，或者创建新项目。'
                        });
                    }

                }
                else {
                    this.tmpVersion = this.data;
                }
            },
            handleSubmit(name) {
                if (!this.data) {
                    // 提交新版本
                    this.$store.dispatch('pushProjectVersion', this[name]).then(res => {
                        if (res.status) {
                            this.versionList.pop();
                            this.versionList.unshift(this[name]);
                            this.$Message.success('修改成功！');
                        } else {
                            this.$Notice.error({
                                title: '修改失败！',
                                desc: '请检查网络状况，并重新点击确认'
                            });
                        }
                    })
                } else {
                    // 保存到 TheNewProject 组件
                    this.$emit('update:data', this[name]);
                    this.$emit('on-ok');
                }
            },
            handleReset(name) {
                this.initData();
            }
        },
        computed: {
            ...mapState({
                defaultIndex: state => state.project.defaultIndex,
                projectList: state => state.project.projectList
            }),
        },
        mounted() {
            this.initData();
        }
    }
</script>

<style scoped>
    .padding {
        padding: 30px 24px;
        background-color: #fff;
        border-radius: 4px;
    }

    .bordered {
        border: 1px solid #dddee1;
        position: relative;
        transition: all .2s ease-in-out;
    }

    .bordered:hover {
        box-shadow: 0 1px 6px rgba(0, 0, 0, .2);
        border-color: #eee;
    }

    .header {
        position: relative;
        font-size: 15px;
        border-bottom: 1px solid #e9eaec;
        top: -14px;
        padding-bottom: 16px;
        line-height: 1;
    }

    .content-layout {
        display: flex;
        flex-flow: row wrap;
        justify-content: space-around;
        align-items: center;
    }

    .content-input > p {
        font-size: 14px;
        margin-bottom: 6px;
    }

    .content-input > div {
        margin-bottom: 24px;
    }

    .content-line {
        margin-top: 16px;
        align-self: flex-start;
        min-width: 180px;
        max-width: 300px;
    }

    .time-line-title {
        font-size: 14px;
        font-weight: bold;
    }

    .time-line-content {
        padding-left: 24px;
    }

    .content-button {
        width: 100%;
        height: 80px;
        line-height: 80px;
        display: inline-block;
        text-align: center;
    }

    .content-button button {
        width: 100px;
    }
</style>
