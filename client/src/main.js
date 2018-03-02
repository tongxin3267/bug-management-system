/**
 * webpack 打包入口，寻找其他依赖
 * 声明与其他组件的依赖关系
 */
import Vue from 'vue';
import App from './App';
import router from './router';
import store from './store';
import iView from 'iview';
import 'iview/dist/styles/iview.css';

import axios from 'axios';
import VueAxios from 'vue-axios';

/* 阻止 vue 在启动时生成生产提示 */
Vue.config.productionTip = false;

Vue.use(iView);
Vue.use(VueAxios, axios);

new Vue({
    el: '#app',
    router,
    store,
    components: { App },
    template: '<App/>'
});
