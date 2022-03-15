import { createStore } from 'vuex'
import store from './store.js';
import createPersistedState from "vuex-persistedstate";

export default createStore({
  modules: {
    store
  },
  plugins: [createPersistedState()]
})
