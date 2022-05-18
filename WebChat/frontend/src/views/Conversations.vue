<template>
  <User />

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

  <div class = "container" v-bind:style = "{ minHeight: $store.getters.WindowHeight + 'px' }">
    <div class = "conversations">
      <router-link id = "back" to = "/"><i class = "fa fa-chevron-left" style = "margin-right: 10px"></i>Back to Contacts</router-link>
      <div class = "heading">
        <h1>Conversations</h1>
        <div class = "add-convo" v-on:click = "startConvoPopup = true"><span>New Conversation</span><i class = "fa fa-plus"></i></div>
      </div>

      <div id = "conversations">
        <div v-for = "convo in conversations" v-bind:key = "convo.name" class = "convo" v-on:click = "navigate('conversations/' + convo.id)">
          <div class = "convo-info">
            <span class = "convo-name">{{ convo.name }}</span>
            <span class = "contact-creator">Creator: {{ convo.creator }}</span>
          </div>
          <div class = "user-list">
            <span>{{ listToText(convo.users) }}</span>
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
  name: 'Conversations',
  components: {
    User
  },
  data() {
    return {
      startConvoPopup: false,
      newConvo: {
        name: "",
        members: []
      }
    }
  },
  computed: {
    ...mapGetters({
      user: 'User',
      contacts: 'Contacts',
      conversations: 'Conversations'
    })
  },
  methods: {
    // navigate (place => router-view location to route to when called), push new location to router stack
    navigate: function(place) {
      this.$router.push("/" + place);
    },


    listToText: function(list) {
      let output = "";
      let complete = true;

      list.forEach(function(el) {
        if (output.length + el.length < 50) {
          output += (el + ", ")
        } else {
          complete = false;
        }
      });

      if (complete) {
        output = output.substring(0, output.length - 2);
      } else {
        output = output + "...";
      }

      return output;
    },

    addConversation: async function() {
      await this.$store.dispatch('MakeConversation', {name: this.newConvo.name, contacts: this.newConvo.members});
      await this.$store.dispatch('GetConversations');
      this.$store.dispatch("Confirmation", "Conversation added successfully");

      this.newConvo = {name: "", members: []};
      this.startConvoPopup = false;
    }
  },
  mounted() {
    this.$store.dispatch('GetConversations');
  }
}
</script>

<style scoped>

#back {
  text-decoration: none;
  position: absolute;
  top: -30px;
  font-size: 15px;
  left: 70px;
  color: #9a4154;
  font-weight: bold;
  font-family: "Nunito", sans-serif;
  transition: color .3s ease;
}

#back:hover {
  color: #ff819c;
}

/* Start conversation popup */
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


/* Main */
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

.conversations {
  border-radius: 40px;
  margin-bottom: 50px;
  padding-bottom: 40px;
  width: 75%;
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  background: white;
  box-shadow: 0 0 5px 2px rgba(17, 21, 33, 0.3);
}

.heading {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  width: 85%;
  padding: 20px 0 15px 0;
  box-sizing: border-box;
  margin: 30px 0 10px 0;
  border-bottom: 1px solid #ff819c;
}

.start-convo-popup .heading {
  margin: 0;
}

h1 {
  font-family: "Nanum Gothic", sans-serif;
  font-size: 40px;
  color: #ff819c;
  font-weight: 500;
  position: relative;
}

.heading .add-convo {
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

.heading .add-convo > span {
  position: absolute;
  width: 120px;
  padding: 0;
  left: 20px;
  display: inline-block;
  overflow: hidden;
  transition: width .3s ease;
}

.heading .add-convo .fa {
  display: inline-block;
  padding: 20px;
  background: #ff819c;
  z-index: 3;
  font-size: 20px;
  transform: rotate(0deg);
  transition: transform .3s ease, padding .1s ease, margin-right .1s ease;
}

.heading .add-convo:hover {
  color: white;
  background: #ff819c;
  width: 180px;
}

.heading .add-convo:hover .fa {
  padding: 10px;
  margin-right: 5px;
  transform: rotate(360deg);
  transition: transform .3s ease, padding .6s ease, margin-right .6s ease;
}


#conversations {
  width: 85%;
  margin-top: 30px;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  flex-direction: column;
}

.convo {
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
  cursor: pointer;
  height: 60px;
}

.convo:hover {
  box-shadow: 0 0 5px 2px rgba(17, 21, 33, 0.3);
  top: -3px;
}

.contact > div {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  width: 50%;
  margin: 0;
}

.convo .user-list {
  justify-content: flex-end;
  width: 50%;
  text-align: right;
}

.convo span {
  line-height: 30px;
  vertical-align: middle;
  margin-top: 10px;
}

.convo .convo-name {
  background: rgba(248, 126, 152, 0.2);
  box-shadow: 0 0 8px 1px rgba(248, 126, 152, 0.5);
  padding: 2px 10px;
  margin-right: 20px;
  height: 30px;
  margin-bottom: 5px;
}




</style>