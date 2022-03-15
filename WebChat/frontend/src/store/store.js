
const state = {
  windowHeight: null,
  user: {
    email: null,
    username: null
  }
};
const getters = {
  WindowHeight: state => state.windowHeight,
  User: state => state.user
};
const actions = {
};
const mutations = {
  setWindowHeight(state) {
    state.windowHeight = window.innerHeight;
  },
  setUser(state, user) {
    state.user = user;
  },
  clearState(state) {
    state.windowHeight = null;
    state.user.email = null;
    state.user.username = null;
  }
};
export default {
  state,
  getters,
  actions,
  mutations
};
