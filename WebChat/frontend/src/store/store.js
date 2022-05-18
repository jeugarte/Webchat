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
  contacts: [],
  conversations: []
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
  async Create() {
    await axios.get("create");
  },
  async RegisterUser({commit}, form) {
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
  async Login({commit}, form) {
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
  },
  async GetContacts({commit}) {
    await axios.post("getContacts", {email: state.user.email}).then(function(response) {
      if (response.data === "Internal Server Error") {
        console.log("Internal Server Error");
      } else {
        commit('setContacts', response.data.data.sort(function(a, b) {return (a.email < b.email) ? -1 : (a.email > b.email ? 1 : 0)}));
      }
    });
  },
  async AddContact(_, contact) {
    await axios.post("addContact", {user_email: state.user.email, contact_email: contact}).then(function(response) {
      if (response.data !== "Success") {
        throw "Error";
      }
    });
  },
  async MakeFavorite(_, contact) {
    await axios.post("makeFavorite", {user_email: state.user.email, contact_email: contact}).then(function(response) {
      if (response.data !== "Success") {
        throw "Error";
      }
    });
  },
  async RemoveFavorite(_, contact) {
    await axios.post("removeFavorite", {user_email: state.user.email, contact_email: contact}).then(function(response) {
      if (response.data !== "Success") {
        throw "Error";
      }
    });
  },
  async GetConversations({commit}) {
    await axios.post("getConversations", {email: state.user.email}).then(function(response) {
      if (response.data === "Internal Server Error") {
        console.log("Internal Server Error");
      } else {
        let conversations = [];

        response.data.data.forEach(function(convo) {

          let creator = convo.creator_email;
          let creatorFiltered = state.contacts.filter(function(contact) {return contact.email === convo.creator_email});
          if (creatorFiltered.length > 0) {
            creator = creatorFiltered[0];
          }

          let users = convo.users;
          users.forEach(function(user) {
            let userFiltered = state.contacts.filter(function(contact) {return contact.email === user});
            if (userFiltered.length > 0) {
              user = userFiltered[0];
            }
          });


          conversations.push({name: convo.conversation_name, id: convo.conversation_id, creator: creator, users: users});
        });

        commit('setConversations', conversations.sort(function(a, b) {return (a.name < b.name) ? -1 : (a.name > b.name ? 1 : 0)}));
      }
    });
  },
  async MakeConversation(_, {name, contacts}) {
    await axios.post("makeConversation", {conversation_name: name, creator_name: state.user.email, contacts: contacts}).then(function(response) {
      if (response.data !== "Success") {
        throw "Error";
      }
    });
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
  },
  setContacts(state, contacts) {
    state.contacts = contacts;
  },
  setConversations(state, conversations) {
    state.conversations = conversations;
  }
};
export default {
  state,
  getters,
  actions,
  mutations
};
