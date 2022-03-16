<template>
  <div class = "container" v-bind:style = "{minHeight: $store.getters.WindowHeight + 'px'}">
    <div class = "past-messages">
      <div class = "view-box" ref = "viewBox">
        <div v-for = "message in pastMessages" v-bind:key = "message.message" v-bind:class = "message.username === user.username ? 'me' : ''"><p>{{ message.message }}</p><span class = "name">{{ message.username }}</span></div>
      </div>
    </div>
    <div class = "inputs">
      <textarea v-on:keydown.enter.exact.prevent v-on:keyup.enter.exact = "postMessage" v-model = "newMessage" placeholder = "New Message"></textarea>
      <button v-on:click = "postMessage" title = "Enter"><i class = "fa fa-paper-plane"></i></button>
    </div>
  </div>
</template>

<script>

import axios from 'axios';
import { mapGetters } from "vuex";


export default {
  name: "Main",
  data() {
    return {
      newMessage: "",
      pastMessages: []
    }
  },
  computed: {
    ...mapGetters({
      user: 'User'
    })
  },
  methods: {
    postMessage: async function() {
      if (this.newMessage !== "") {
        await axios.post("postMessage", {username: this.user.username, message: this.newMessage});
        this.newMessage = "";
        await this.getMessages();
      }
    },
    getMessages: async function() {
      let self = this;
      let oldMessagesLength = this.pastMessages.length;
      await axios.get("getMessages").then(function(response) {
        self.pastMessages = response.data.data.reverse();
        if (self.pastMessages.length > oldMessagesLength) {
          window.setTimeout(function() {
            self.$refs.viewBox.scrollTop = self.$refs.viewBox.scrollHeight;
          }, 0);
        }
      });
    }
  },
  mounted() {
    let self = this;
    this.getMessages();
    window.setTimeout(function() {
      this.$refs.viewBox.scrollTop = this.$refs.viewBox.scrollHeight;
    }, 0);
    console.log(this.user);
    window.setInterval(this.getMessages, 100);
  }
}
</script>

<style scoped>

.container {
  width: 100%;
  position: relative;
  margin: 0 !important;
  display: flex;
  justify-content: center;
  align-items: center;
  background-image: linear-gradient(to bottom right, pink, white);
  flex-direction: column;
  padding: 65px 0;
  box-sizing: border-box;
}

.container * {
  text-align: center;
}

.past-messages {
  max-width: 800px;
  height: 500px;
  width: 95%;
  box-sizing: border-box;
  border: 1px solid #cccccc;
  border-radius: 35px;
  padding: 30px 10px;
  margin-top: -50px;
  background: white;
  position: relative;
  top: 0;
  box-shadow: 0 0 10px 4px rgba(17, 21, 33, 0.2);
}

.past-messages .view-box {
  overflow: auto;
  height: 100%;
  padding: 0 50px;
}

.past-messages div {
  margin-bottom: 20px;
  text-align: left;
}

.past-messages div p {
  text-align: left;
  white-space: pre-wrap;
}

.past-messages div span {
  opacity: 0.8;
  margin-top: -1px;
  display: block;
  font-size: 8pt;
  text-align: left;
}

.past-messages div.me {
  text-align: right;
  color: #fa7e92;
}

.past-messages div.me * {
  text-align: right;
}

.inputs {
  max-width: 760px;
  width: 90%;
  box-sizing: border-box;
  border: 1px solid #cccccc;
  border-radius: 50px;
  padding: 10px 10px 10px 30px;
  background: white;
  position: relative;
  top: 10px;
  box-shadow: 0 0 10px 0.5px rgba(17, 21, 33, 0.3);
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}

.inputs textarea {
  font-family: "Nunito", sans-serif;
  border: none;
  outline: none;
  resize: none;
  text-align: left;
  height: 23px !important;
  padding: 0;
  margin-top: 5px;
  box-sizing: border-box;
  /*line-height: 23px;*/
  width: 80% !important;
}

.inputs button {
  background: #fa7e92;
  border: none;
  font-family: "Nunito", sans-serif;
  width: 40px;
  height: 40px;
  border-radius: 20px;
  color: white;
  cursor: pointer;
}

</style>