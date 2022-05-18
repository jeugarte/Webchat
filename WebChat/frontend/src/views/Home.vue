<template>
  <User />

  <!-- Add contact popup -->
  <div class = "add-contact-popup" v-on:keyup.enter = "addContact" v-if = "addContactPopup" v-bind:style = "{height: $store.getters.WindowHeight + 'px'}">
    <div class = "add-contact-content">
      <div class = "heading">
        <h1>Add Contact</h1>
        <div class = "heading-buttons">
          <button v-on:click = "addContactPopup = false; newContact = ''" class = "cancel"><span>Cancel</span><i class = "fa fa-times"></i></button>
        </div>
      </div>
      <div class = "inputs">
        <div class = "email-input">
          <span>Email:</span>
          <input v-model = "newContact">
        </div>
        <div class = "submit" v-on:click = "addContact"><span>Submit</span></div>
      </div>
    </div>
  </div>

  <!-- Start conversation popup -->
  <div class = "start-convo-popup" v-on:keyup.enter = "addConversation" v-if = "startConvoPopup" v-bind:style = "{height: $store.getters.WindowHeight + 'px'}">
    <div class = "start-convo-content">
      <div class = "heading">
        <h1>Start Conversation</h1>
        <div class = "heading-buttons">
          <button v-on:click = "startConvoPopup = false; newConvo = {name: '', members: []}" class = "cancel"><span>Cancel</span><i class = "fa fa-times"></i></button>
        </div>
      </div>
      <div class = "inputs">
        <div class = "inputs-outer">
          <div class = "name-input">
            <span>Conversation Name:</span>
            <input v-model = "newConvo.name">
          </div>
          <div class = "submit" v-on:click = "addConversation"><span>Submit</span></div>
        </div>
        <div class = "members-input">
          <span>Members:</span>
          <select v-model = "newConvo.members" multiple>
            <option v-for = "contact in contacts" v-bind:key = "contact.email" v-bind:value = "contact.email">{{ contact.username }}</option>
          </select>
        </div>
      </div>
    </div>
  </div>


  <!-- Main content -->
  <div class = "container" v-bind:style = "{ minHeight: $store.getters.WindowHeight + 'px' }">
    <div class = "content">
      <div class = "top-bar">
        <div id = "profile">
          <!-- Avatar -->
          <div class = "avatar">
            <i class = "fa fa-user-circle-o img"></i>
          </div>

          <!-- User info -->
          <div class = "profile-info">
            <div class = "username" v-bind:style = "{'box-shadow': editingName ? '0 0 10px 1px rgba(17, 21, 33, 0.3)' : 'none'}">
              <input v-bind:readonly = "!editingName" v-model = "username" ref = "nameInput">
              <i v-if = "editingName" class = "fa fa-times close" v-on:click = "cancelNameEdit"></i>
              <i class = "fa" v-bind:class = "editingName ? 'fa-check' : 'fa-pencil'" v-on:click = "editName" v-bind:style = "{color: editingName ? 'rgb(5, 178, 0)' : 'black'}"></i>
            </div>
            <div class = "email">{{ user.email }}</div>
          </div>
        </div>

        <router-link to = "/conversations" class = "chats">Conversations</router-link>
      </div>
      <div class = "contacts">
        <div class = "heading">
          <h1>Contacts</h1>
          <div class = "add-contact" v-on:click = "addContactPopup = true"><span>New Contact</span><i class = "fa fa-plus"></i></div>
        </div>

        <div id = "contacts">
          <div v-for = "contact in contacts" v-bind:key = "contact.email" class = "contact">
            <div class = "contact-info">
              <span class = "contact-email">{{ contact.email }}</span>
              <span class = "contact-username">{{ contact.username }}</span>
            </div>
            <div class = "convo-info">
              <span class = "convo-num">{{ contact.num }} Conversations</span>
              <span v-on:click = "startConvoPopup = true; newConvo.members = [contact.email]" class = "start-convo" title = "Start conversation with contact"><i class = "fa fa-plus"></i></span>
            </div>
            <div class = "fav-info">
              <span class = "favorite" v-on:click = "toggleFavorite(contact)" v-bind:title = "contact.favorite ? 'Unfavorite contact' : 'Favorite contact'"><i class = "fa" v-bind:class = "contact.favorite ? 'fa-star' : 'fa-star-o'"></i></span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import User from '../components/User.vue'
import {mapGetters} from "vuex";

export default {
  name: 'Home',
  components: {
    User
  },
  data() {
    return {
      editingName: false,
      username: "",
      addContactPopup: false,
      startConvoPopup: false,
      newContact: "",
      newConvo: {
        name: "",
        members: []
      },
    }
  },
  computed: {
    ...mapGetters({
      user: 'User',
      contacts: 'Contacts'
    })
  },
  methods: {
    // editName, change username of user to what is currently typed in
    editName: function() {
      if (this.editingName) {
        // If name input is currently focused, then dispatch change username actions
        let self = this;
        this.$store.commit('setProcessing', true);
        this.$store.dispatch('SetUserName', this.username).then(() => {
          self.$store.commit('setProcessing', false);
          self.$store.dispatch("Confirmation", "Username changed successfully");
        });
      } else {
        // Otherwise, focus it
        this.$refs.nameInput.focus();
      }

      // Change editing state
      this.editingName = !this.editingName;
    },

    // cancelNameEdit, stop editing name and reset name to what was previously saved
    cancelNameEdit: function() {
      this.username = this.user.username;
      this.editingName = false;
    },

    addContact: async function() {
      this.$store.commit('setProcessing', true);
      try {
        await this.$store.dispatch('AddContact', this.newContact);
        await this.$store.dispatch('GetContacts');
        this.$store.commit('setProcessing', false);
        this.$store.dispatch("Confirmation", "Contact added successfully");
      } catch (_) {
        this.$store.commit('setProcessing', false);
        this.$store.dispatch("Confirmation", "Not a valid contact");
      }
      this.newContact = "";
      this.addContactPopup = false;
    },
    addConversation: async function() {
      await this.$store.dispatch('MakeConversation', {name: this.newConvo.name, contacts: this.newConvo.members});
      await this.$store.dispatch('GetConversations');
      this.$store.dispatch("Confirmation", "Conversation added successfully");

      this.newConvo = {name: "", members: []};
      this.startConvoPopup = false;
    },
    toggleFavorite: async function(contact) {
      if (contact.favorite) {
        await this.$store.dispatch('RemoveFavorite', contact.email);
        this.$store.dispatch("Confirmation", contact.username + " unfavorited");
      } else {
        await this.$store.dispatch('MakeFavorite', contact.email);
        this.$store.dispatch("Confirmation", contact.username + " favorited");
      }
      await this.$store.dispatch('GetContacts');
    }
  },
  mounted() {
    this.$store.dispatch('GetContacts');
  },
  created() {
    this.username = this.user.username;
  }
}
</script>

<style scoped>

/* Add contact popup */
.add-contact-popup {
  position: fixed;
  top: 0;
  width: 100%;
  z-index: 100;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  background: rgba(0, 0, 0, 0.1);
}

.add-contact-content {
  width: 65%;
  margin-top: -50px;
  border-radius: 50px;
  position: relative;
  background: white;
  box-sizing: border-box;
  height: auto;
  padding: 20px 10px 35px 10px;
  max-height: 85%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  box-shadow: 0 0 10px 2px rgba(17, 21, 33, 0.3);
}

.heading-buttons {
  display: flex;
  flex-direction: row;
}

.submit {
  color: #ff819c;
  background: white;
  position: relative;
  width: 90px;
  border: 1px solid #ff819c;
  display: flex;
  align-items: center;
  justify-content: center;
  box-sizing: border-box;
  overflow: hidden;
  padding: 0;
  height: 50px;
  border-radius: 17px;
  font-family: "Nunito", sans-serif;
  font-size: 14px;
  box-shadow: 0 0 2px 0.6px rgba(17, 21, 33, 0.3);
  cursor: pointer;
  transition: color .3s ease, background .3s ease, border-radius .3s ease;
}

.submit:hover {
  color: white;
  background: #ff819c;
  border-radius: 5px;
}

.cancel {
  background: none;
  outline: none;
  margin-top: 10px;
  font-size: 20px;
  cursor: pointer;
  color: #ff3f49;
  border-radius: 10px;
  border: 1px solid #ff3f49;
  transition: transform .3s ease;
  display: flex;
  height: 35px;
  padding: 0 7px;
  justify-content: center;
  align-items: center;
  flex-direction: row;
}

.cancel span {
  width: 0;
  display: inline-block;
  overflow: hidden;
  font-size: 13px;
  margin: 0;
  transition: width .3s ease, margin-right .3s ease;
}

.cancel:hover span {
  width: inherit;
  margin: 0 5px;
}

.cancel:hover .fa {
  transform: rotate(90deg);
}

.inputs {
  margin-top: 20px;
  width: 85%;
  font-family: "Antic", sans-serif;
  font-size: 20px;
  display: flex;
  flex-direction: row;
  color: #a96d7a;
}

.inputs .email-input {
  width: 90%;
}

.inputs input {
  border-radius: 0;
  width: 80%;
  border: 1px solid #a8a8a8;
  color: #333;
  background-color: transparent;
  outline: none;
  font-family: "Montserrat", sans-serif;
  padding: 8px 10px;
  height: 20px;
  margin-top: 5px;
  margin-left: 10px;
}


/* Start convo popup */
.start-convo-popup {
  position: fixed;
  top: 0;
  width: 100%;
  z-index: 100;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  background: rgba(0, 0, 0, 0.1);
}

.start-convo-content {
  width: 65%;
  margin-top: -50px;
  border-radius: 50px;
  position: relative;
  background: white;
  box-sizing: border-box;
  height: auto;
  padding: 20px 10px 35px 10px;
  max-height: 85%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  box-shadow: 0 0 10px 2px rgba(17, 21, 33, 0.3);
}

.start-convo-popup .inputs {
  flex-direction: column;
}

.start-convo-popup .inputs-outer {
  width: 100%;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
}

.name-input input {
  width: 200px;
}

.members-input {
  margin-top: 20px;
  width: 100%;
}

.members-input select {
  width: calc(100% - 100px);
  margin-left: 10px;
  outline: none;
  border-radius: 0;
  border: 1px solid #a8a8a8;
  color: #333;
  background-color: transparent;
  font-family: "Montserrat", sans-serif;
  padding: 8px 10px;
  height: 100px;
  overflow: visible;
  margin-top: 5px;

}


/* Container */
.container {
  width: 100%;
  position: relative;
  margin: 0 !important;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  background-image: linear-gradient(to bottom right, pink, white);
  flex-direction: column;
  padding-top: 100px;
  box-sizing: border-box;
}

.content {
  width: 75%;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}

.top-bar {
  width: 100%;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: center;
}

/* User profile styling */
#profile {
  background: white;
  border-radius: 40px;
  width: 50%;
  box-shadow: 0 0 5px 1px rgba(17, 21, 33, 0.3);
  border: none;
  padding: 25px 40px;
  transition: box-shadow .3s ease;
  height: 140px;
  margin-bottom: 20px;
  box-sizing: border-box;
  display: flex;
  flex-direction: row;
  align-items: center;
}

.avatar {
  color: #fa7e92;
  cursor: pointer;
  border-radius: 50%;
  position: relative;
}

.avatar .img {
  font-size: 100px;
}

.profile-info {
  margin-left: 30px;
  padding: 8px 15px 15px 0;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
  align-items: flex-start;
  height: 90%;
}

.email {
  font-family: "Montserrat", sans-serif;
  font-size: 13px;
  margin-top: 15px;
}

.username {
  font-family: "Montserrat", sans-serif;
  font-size: 14px;
  width: 150px;
  border: 1px solid rgba(29, 34, 41, 0.2);
  border-radius: 6px;
  padding: 8px 12px;
  position: relative;
  transition: box-shadow .3s ease;
}

.username input {
  border: none;
  padding: 0;
  outline: none;
  font-family: "Montserrat", sans-serif;
  font-size: 14px;
}

.username .fa {
  position: absolute;
  right: 10px;
  top: 9px;
  cursor: pointer;
}

.username .close {
  right: 30px;
  color: #ff2540;
}

@media only screen and (max-width: 990px) {
  .top-bar {
    flex-direction: column;
  }

  #profile {
    width: 100%;
  }
}

@media only screen and (max-width: 500px) {
  #profile {
    flex-direction: column;
    height: inherit;
    width: 100%;
  }

  .profile-info {
    height: 165px;
    margin-left: 0;
    align-items: center;
  }

  .username {
    width: 100%;
    margin-left: 20px;
  }

  .username input {
    width: inherit;
  }
}


.chats {
  background: white;
  border: 1px solid #ff819c;
  border-radius: 40px;
  width: 200px;
  box-shadow: 0 0 5px 1px rgba(17, 21, 33, 0.3);
  height: 80px;
  margin-bottom: 30px;
  box-sizing: border-box;
  display: inline-block;
  flex-direction: row;
  align-items: center;
  text-decoration: none !important;
  text-align: center;
  font-family: "Nunito", sans-serif;
  font-size: 20px;
  color: #ff819c;
  vertical-align: middle;
  line-height: 80px;
  transition: border-radius .3s ease, background .3s ease, color .3s ease;
  cursor: pointer;
}

.chats:hover {
  border-radius: 5px;
  background: #ff819c;
  color: white;
}


.contacts {
  border-radius: 40px;
  margin-bottom: 80px;
  padding: 30px 20px 60px 20px;
  width: 100%;
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  background: white;
  box-shadow: 0 0 5px 1px rgba(17, 21, 33, 0.3);
}

.heading {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  width: 85%;
  padding: 20px 0 15px 0;
  box-sizing: border-box;
  border-bottom: 1px solid #ff819c;
}

h1 {
  font-family: "Nanum Gothic", sans-serif;
  font-size: 40px;
  color: #ff819c;
  font-weight: 500;
  position: relative;
}

.heading .add-contact {
  color: white;
  background: #ff819c;
  position: relative;
  width: 58px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  box-sizing: border-box;
  overflow: hidden;
  padding: 0;
  transition: width .3s ease;
  height: 50px;
  border-radius: 17px;
  margin: 0 10px 10px 0;
  line-height: 50px;
  font-family: "Nunito", sans-serif;
  font-size: 14px;
  box-shadow: 0 0 5px 2px rgba(17, 21, 33, 0.3);
  cursor: pointer;
}

.heading .add-contact > span {
  position: absolute;
  width: 120px;
  padding: 0;
  left: 20px;
  display: inline-block;
  overflow: hidden;
  transition: width .3s ease;
}

.heading .add-contact .fa {
  display: inline-block;
  padding: 20px;
  background: #ff819c;
  z-index: 3;
  font-size: 20px;
  transform: rotate(0deg);
  transition: transform .3s ease, padding .1s ease, margin-right .1s ease;
}

.heading .add-contact:hover {
  color: white;
  background: #ff819c;
  width: 170px;
}

.heading .add-contact:hover .fa {
  padding: 10px;
  margin-right: 5px;
  transform: rotate(360deg);
  transition: transform .3s ease, padding .6s ease, margin-right .6s ease;
}

#contacts {
  width: 85%;
  margin-top: 30px;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  flex-direction: column;
}

.contact {
  color: #4a4a4a;
  font-family: "Nunito", sans-serif;
  font-size: 14px;
  background: white;
  top: 0;
  transition: box-shadow .3s ease, border .3s ease, top .3s ease;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  position: relative;
  border-top: 0.5px solid rgba(17, 21, 33, 0.3);
  padding: 0 10px;
  margin: 0;
  height: 60px;
}

.contact:hover {
  box-shadow: 0 0 4px 1px rgba(17, 21, 33, 0.3);
  top: -3px;
}

.contact > div {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  width: 50%;
  margin: 0;
}

.contact .convo-info {
  justify-content: flex-end;
  width: 30%;
}

.contact .fav-info {
  justify-content: flex-end;
  width: 20%;
}

.contact span {
  line-height: 30px;
  vertical-align: middle;
  margin-top: 10px;
}

.contact .contact-email {
  background: rgba(248, 126, 152, 0.2);
  box-shadow: 0 0 8px 1px rgba(248, 126, 152, 0.5);
  padding: 2px 10px;
  margin-right: 20px;
  height: 30px;
  margin-bottom: 5px;
}

.contact .convo-num {
  margin-right: 20px;
}

.contact .start-convo {
  color: #ff819c;
  background: white;
  position: relative;
  width: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-sizing: border-box;
  overflow: hidden;
  padding: 0;
  border-radius: 10px;
  margin: 10px 10px 10px 0;
  height: 30px;
  font-size: 14px;
  cursor: pointer;
  border: 1px solid #ff819c;
  transition: color .3s ease, background .3s ease, border-radius .3s ease;
}

.contact .start-convo:hover {
  color: white;
  background: #ff819c;
  border-radius: 2px;
}

.contact .favorite {
  font-size: 25px;
  line-height: 50px;
  vertical-align: middle;
  height: 60px;
  margin-right: 10px;
  color: #ff819c;
}

.contact .favorite .fa {
  cursor: pointer;
  transition: transform .3s ease;
}

.contact .favorite .fa:hover {
  transform: rotate(144deg)
}

</style>