import axios from "axios";

const state = {
  windowHeight: null,
  windowWidth: null,
  processing: false,
  confirmations: [],
  user: {
    email: null,
    username: null
  },
  contacts: [
    {
      email: "test@gmail.com",
      username: "test",
      favorite: true,
      num: 5
    },
    {
      email: "hello@gmail.com",
      username: "HELLO",
      favorite: false,
      num: 1
    },
    {
      email: "owen.wetherbee@gmail.com",
      username: "Oe358",
      favorite: false,
      num: 0
    },
    {
      email: "ocw6@gmail.com",
      username: "ocw6",
      favorite: true,
      num: 120
    },
    {
      email: "s019628@gmail.com",
      username: "Student",
      favorite: false,
      num: 10
    }
  ],
  conversations: [
    {
      id: 1,
      name: "Conversation 1",
      creator: "ocw6@gmail.com",
      users: ["sjj@gmail.com", "hello@gmail.com", "test@gmail.com"]
    },
    {
      id: 2,
      name: "FUN TIMES",
      creator: "owen.wetherbee@gmail.com",
      users: ["sjj@gmail.com", "ocw6@gmail.com", "test@gmail.com"]
    }
  ]
};
const getters = {
  Confirmations: state => state.confirmations,
  Processing: state => state.processing,
  WindowHeight: state => state.windowHeight,
  WindowWidth: state => state.windowWidth,
  User: state => state.user,
  Contacts: state => state.contacts,
  Conversations: state => state.conversations
};
const actions = {
  async Confirmation({commit}, message) {
    let id = Math.floor(Math.random() * 100000000);
    commit('addConfirmation', {
      id: id,
      message: message
    });
    setTimeout(function() {
      commit('removeConfirmation', id);
    }, 2000);
  },
  async create() {
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
  },
  async SetUserName({commit, getters}, name) {
    // set user name endpoint
    commit('setUserName', {email: state.user.email, username: name});
  }
};
const mutations = {
  setProcessing(state, processing) {
    state.processing = processing;
  },
  addConfirmation(state, confirmation) {
    state.confirmations.push(confirmation);
  },
  removeConfirmation(state, id) {
    for (let i = 0; i < state.confirmations.length; i++) {
      if (state.confirmations[i].id === id) {
        state.confirmations.splice(i, 1);
        break;
      }
    }
  },
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
