<template>
  <div class = "container">
    <div class = "past-messages">
      <p v-for = "message in pastMessages" v-bind:key = "message.message">{{ message.username }}: {{ message.message }}</p>
    </div>
    <div class = "inputs">
      <p> Current User: {{ user.username }}</p>
      <textarea v-model = "newMessage" placeholder = "New Message"> </textarea>
      <br>
      <button v-on:click = "postMessage">ENTER</button>
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
    postMessage: function() {
      axios.post("postMessage", {username: this.user.username, message: this.newMessage});
      this.newMessage = "";
      this.getMessages();
    },
    getMessages: function() {
      let self = this;
      axios.get("getMessages").then(function(response) {
        self.pastMessages = response.data.data;
      });
    }
  },
  mounted() {
    this.getMessages();
    console.log(this.user);
    window.setInterval(this.getMessages, 100);
  }
}
</script>

<style scoped>

.container {
  text-align: center;
}

.container * {
  text-align: center;
}

</style>