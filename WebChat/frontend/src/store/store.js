
const state = {
  windowHeight: null
};
const getters = {
  WindowHeight: state => state.windowHeight
};
const actions = {

};
const mutations = {
  setWindowHeight(state) {
    state.windowHeight = window.innerHeight;
  }
};
export default {
  state,
  getters,
  actions,
  mutations
};
