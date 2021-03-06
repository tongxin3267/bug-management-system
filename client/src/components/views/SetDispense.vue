<template>
    <Card :padding="0">
        <Tabs v-model="tab" type="card">
            <TabPane label="解决人员分配" name="1">
                <base-table :columns="columns[0]"
                            :data="dataList0"
                            :page-size="10"
                            @on-row-click="showModal"
                            class="tab-table"></base-table>
            </TabPane>
            <TabPane label="测试人员分配" name="2">
                <base-table :columns="columns[1]"
                            :data="dataList1"
                            :page-size="10"
                            @on-row-click="showModal"
                            class="tab-table"></base-table>
            </TabPane>
        </Tabs>
        <Modal v-model="modal"
               :mask-closable="false"
               :closable="false">
            <div slot="header" class="header-font">
                <Icon type="log-out" class="icon-color"></Icon>
                <span>分配</span>
            </div>
            <div>
                <span style="font-size: 14px">{{ inputName }}</span>
                <AutoComplete v-model="people"
                              size="large"
                              transfer
                              clearable
                              @on-search="peopleSearch"
                              class="auto-input">
                    <Option v-for="item in optionData" :value="item.name" :key="item.id">
                        {{ item.name }}
                    </Option>
                </AutoComplete>
            </div>
            <div slot="footer">
                <Button type="text" size="large" @click="resetIssue">取消</Button>
                <Button type="primary" size="large" @click="submitIssue">确定</Button>
            </div>
        </Modal>
    </Card>
</template>

<script>
    import {mapState} from 'vuex';
    import BaseTable from '../base/BaseTable';

    export default {
        name: "SetDispense",
        components: {
            BaseTable
        },
        data() {
            return {
                tab: '1',
                columns: [
                    [
                        {type: 'index', width: 60, title: '序号', align: 'center'},
                        {title: '标题', key: 'title'},
                        {title: '类型', key: 'select'},
                        {title: '模块', key: 'module'},
                        {title: '版本号', key: 'version', sortable: true},
                        {title: '优先级', key: 'priority', sortable: true},
                        {title: '提交', key: 'issuer', sortable: true},
                    ],
                    [
                        {type: 'index', width: 60, title: '序号', align: 'center'},
                        {title: '标题', key: 'title'},
                        {title: '类型', key: 'select'},
                        {title: '模块', key: 'module'},
                        {title: '版本号', key: 'version', sortable: true},
                        {title: '优先级', key: 'priority', sortable: true},
                        {title: '提交', key: 'issuer', sortable: true},
                        {title: '解决', key: 'developer', sortable: true}
                    ]
                ],
                modal: false,
                people: '',
                optionData: [],    // 下拉列表实际显示的数据
                optionList: [],    // 下拉列表总数据
                inputName: '',
                issueIndex: [],  // 所有问题 id 列表，用于快速查找选中问题的索引
                clickRowIndex: ''     // 被选中的问题的索引
            }
        },
        methods: {
            submitIssue() {
                const list = this.optionList.map(item => item.name);
                if (list.includes(this.people)) {
                    this.optionList.forEach(item => {
                        if (item.name === this.people) {
                            let tmpData = JSON.parse(JSON.stringify(this.issueList[this.clickRowIndex]));
                            if (this.tab === '1') {
                                tmpData.developer = item.id;
                                tmpData.status = 1;
                            } else if (this.tab === '2') {
                                tmpData.tester = item.id;
                                tmpData.status = 3;
                            }
                            tmpData.dispense = this.userId;
                            this.$store.dispatch('dispenseIssue', tmpData).then(res => {
                                if (res.status) {
                                    this.issueList[this.clickRowIndex].dispense = tmpData.dispense;
                                    this.issueList[this.clickRowIndex].developer = tmpData.developer;
                                    this.issueList[this.clickRowIndex].tester = tmpData.tester;
                                    this.issueList[this.clickRowIndex].status = tmpData.status;
                                } else {
                                    this.$Message.error('分配失败!');
                                }
                            });
                        }
                    });
                    this.modal = false;
                    this.$Message.success('分配成功!');
                } else {
                    this.$Loading.error();
                    this.$Message.error('人员有误!');
                }
            },
            resetIssue() {
                this.modal = false;
            },
            // 显示对话框
            showModal(row) {
                this.clickRowIndex = this.issueIndex.indexOf(row.id);
                const peopleData = this.projectList[this.defaultIndex].people;
                if (this.tab === '1') {
                    // 解决人员分配
                    this.inputName = '选择解决人员：';
                    this.optionList = peopleData.filter(item => item.permission[4] === '1')
                        .map(item => {
                            return {
                                'name': item.name,
                                'id': item.userId
                            }
                        });
                } else if (this.tab === '2') {
                    // 测试人员分配
                    this.inputName = '选择测试人员：';
                    this.optionList = peopleData.filter(item => item.permission[5] === '1')
                        .map(item => {
                            return {
                                'name': item.name,
                                'id': item.userId
                            }
                        });
                }
                this.modal = true;
            },
            // 输入框下拉列表的人员搜索
            peopleSearch(val) {
                if (val) {
                    this.optionData = this.optionList.filter(item => item.name.search(val) >= 0)
                        .slice(-5);
                } else {
                    this.optionData = [];
                }
            },
            /**
             * 成员 id 转换为昵称
             * @param oldData 旧对象
             * @returns {object} 新对象
             */
            userIdToName(oldData) {
                const attributes = ['issuer', 'dispense', 'developer', 'tester'];
                const peopleData = this.projectList[this.defaultIndex].people;
                oldData.forEach(item => {
                    peopleData.forEach(i => {
                        for (let j = 0; j < attributes.length; j++) {
                            if (i.userId === item[attributes[j]]) {
                                item[attributes[j]] = i.name;
                            }
                        }
                    })
                });
                return oldData;
            },
            checkPermission() {
                if (!this.permission || this.permission[3] !== '1') {
                    this.$router.push({name: 'myProject'});
                    this.$root.Bus.$emit('closeComponent', 'SetDispense');
                    this.$Notice.warning({
                        title: '没有操作权限！',
                        desc: '请联系项目管理人员，分配职责。'
                    });
                }
            }
        },
        computed: {
            ...mapState({
                projectList: state => state.project.projectList,
                defaultIndex: state => state.project.defaultIndex,
                issueList: state => state.issue.issueList,
                permission: state => state.user.permission
            }),
            // 表格总来源数据
            issueData() {
                return this.userIdToName(this.issueList.map(item => Object.assign({}, item)));
            },
            // 表格当前显示的数据
            dataList0() {
                return this.issueData.filter(item => item.status === 0);
            },
            dataList1() {
                return this.issueData.filter(item => item.status === 2);
            }
        },
        created() {
            this.checkPermission();
        },
        mounted() {
            this.issueIndex = this.issueList.map(item => item.id);
        }
    }
</script>

<style scoped>
    .header-font {
        font-size: 14px;
        font-weight: 600;
    }

    .icon-color {
        color: #2d8cf0;
        font-size: 16px;
    }

    .auto-input {
        padding: 16px 0;
    }

    .tab-table {
        padding: 0 16px;
    }
</style>
