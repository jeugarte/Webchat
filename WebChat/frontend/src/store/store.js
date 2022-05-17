import axios from "axios";

const state = {
  windowHeight: null,
  windowWidth: null,
  user: {
    email: null,
    username: null
  }
};
const getters = {
  WindowHeight: state => state.windowHeight,
  WindowWidth: state => state.windowWidth,
  User: state => state.user
};
const actions = {
  async create() {
    await axios.get("close");
    await axios.get("create");
  },
  async registerUser({commit}, form) {
    await axios.post("register",
      {email: form.email, password: form.password, username: form.username}).
    then(function(response) {
      if (response.data === "Success") {
        commit('setUser', {username: form.username, email: form.email});
      } else {
        throw response.data;
      }
    });
  },
  async login({commit}, form) {
    await axios.post("login",
      {email: form.user, password: form.password, username: form.user}).
    then(function(response) {
      if (response.data === "No User") {
        throw response.data;
      } else {
        commit('setUser', {username: response.data.username, email: response.data.email});
      }
    });
  }
};
const mutations = {
  setWindowHeight(state) {
    state.windowHeight = window.innerHeight;
  },
  setWindowWidth(state) {
    state.windowWidth = window.innerWidth;
  },
  setUser(state, user) {
    state.user = {email: user.email, username: user.username};
  },
  logOut(state) {
    state.user = {email: null, username: null};
  }
};
export default {
  state,
  getters,
  actions,
  mutations
};
