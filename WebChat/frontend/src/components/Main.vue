<template>
  <div>
    <div class = "past-messages">
      <p v-for = "message in pastMessages" v-bind:key = "message.message">{{ message.username }}: {{ message.message }}</p>
    </div>
    <div class = "inputs">
      <p> Current User: {{ currentUser }}
      <input v-model = "currentUser" placeholder = "Username">
      </p>
      <textarea v-model = "newMessage" placeholder = "New Message"> </textarea>
      <br>
      <button v-on:click = "postMessage">ENTER</button>
    </div>
  </div>
</template>

<script>

import axios from 'axios';

export default {
  name: "Main",
  data() {
    return {
      newMessage: "",
      pastMessages: [],
      currentUser: ""
    }
  },
  methods: {
    postMessage: function() {
      axios.post("http://localhost:3000/messages", {username: this.currentUser, message: this.newMessage});
      this.newMessage = "";
      this.getMessages();
    },
    getMessages: function() {
      let self = this;
      axios.get("http://localhost:3000/messages").then(function(response) {
        self.pastMessages = response.data.data;
      });
    }
  },
  mounted() {
    this.getMessages();
    window.setInterval(this.getMessages, 100);
  }
}
</script>

<style scoped>

.past-messages {

}

</style>