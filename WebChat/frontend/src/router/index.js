import { createRouter, createWebHashHistory } from 'vue-router'
import Home from '../views/Home.vue'
import store from '@/store';


const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home,
    meta: {requiresAuth: true}
  },
  {
    path: '/conversations',
    name: 'Conversations',
    component: () => import(/* webpackChunkName: "about" */ '../views/Conversations.vue'),
    meta: {requiresAuth: true}
  },
  {
    path: '/conversations/:convoID',
    name: 'Chat',
    component: () => import(/* webpackChunkName: "about" */ '../views/Chat.vue'),
    meta: {requiresAuth: true}
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import(/* webpackChunkName: "about" */ '../views/Register.vue'),
    meta: {requiresAuth: false}
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import(/* webpackChunkName: "about" */ '../views/Login.vue'),
    meta: {requiresAuth: false}
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const user = store.getters.User;
  if (to.meta.requiresAuth && user.email === null) {
    next("/login");
  } else {
    next();
  }
});


export default router
