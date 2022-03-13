<template>
  <img alt="Vue logo" src="./assets/logo.png">
  <HelloWorld v-bind:msg="message"/>
</template>

<script>
import HelloWorld from './components/HelloWorld.vue'

import axios from 'axios'

export default {
  name: 'App',
  components: {
    HelloWorld
  },
  data() {
    return {
      message: ""
    }
  },
  mounted() {
    let self = this;
    console.log("Mounted");
    axios.get("http://localhost:3000/hello/stanley").then(function(response) {
      console.log(response);
      self.message = response.data;
    });
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
