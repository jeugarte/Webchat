<template>
  <div id = "user-container" v-if = "$store.getters.WindowWidth > 700">
    <!-- User summary -->
    <div id = "user" v-on:click = "navigate('')">
      <div class = "img avatar">
        <i class = "fa fa-user-circle-o" aria-hidden = "true"></i>
      </div>
      <div class = "text">{{ user.username }}</div>
    </div>

    <!-- Dropdown menu (on hover) -->
    <div id = "user-menu">
      <!-- Conversations button -->
      <div class = "link-button" v-on:click = "navigate('conversations')">
        <i class = "fa fa-list-ul" aria-hidden = "true"></i>
        <div class = "text" style = "font-size: 14px">Conversations</div>
      </div>

      <!-- Logout button -->
      <div class = "link-button" v-on:click = "logOut">
        <i class = "fa fa-power-off" aria-hidden = "true"></i>
        <div class = "text">Logout</div>
      </div>
    </div>
  </div>
</template>

<script>

// Imports
import { mapGetters } from "vuex";

export default {
  name: "User",
  computed: {
    // Map "StateUser" from store to "user" component variable
    ...mapGetters({
      user: 'User'
    })
  },
  methods: {
    // navigate (place => router-view location to route to when called), push new location to router stack
    navigate: function(place) {
      this.$router.push("/" + place);
    },

    // async logOut, log user out (LogOut store action) and route to login page
    async logOut () {
      await this.$store.commit('logOut');
      await this.$router.push('/login');
    }
  }
}
</script>

<style scoped>

  /* Container styling */
  #user-container {
    position: fixed;
    width: inherit;
    height: 50px;
    right: 110px;
    top: 0;
    z-index: 1000;
  }

  /* User summary styling */
  #user {
    border-bottom: 2px solid #fa7e92;
    position: relative;
    height: 50px;
    padding: 0 30px;
    min-width: 100px;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: #fa7e92;
    transition: top .5s ease .2s;
  }

  #user::before {
    content: "";
    position: absolute;
    bottom: 0;
    left: 0;
    height: 0;
    width: 2px;
    background: #fa7e92;
    transition: height .25s ease;
  }

  #user::after {
    content: "";
    position: absolute;
    bottom: 0;
    right: 0;
    height: 0;
    width: 2px;
    background: #fa7e92;
    transition: height .25s ease;
  }

  #user .text {
    font-size: 15px;
    margin-left: 10px;
    /*color: rgb(29, 34, 41);*/
    color: #fa7e92;
    font-family: "Montserrat", sans-serif;
  }

  #user .fa {
    font-size: 22px;
  }

  /* User menu styling */
  #user-menu {
    position: relative;
    opacity: 0;
    display: flex;
    border-top: 7px solid transparent;
    cursor: pointer;
    flex-direction: column;
    justify-content: center;
    visibility: hidden;
    transition: top .25s ease, opacity .25s ease, visibility .0s ease .25s;
  }

  #user:hover::before {
    height: 50px;
  }

  #user:hover::after {
    height: 50px;
  }

  #user:hover + #user-menu, #user-menu:hover {
    opacity: 1;
    visibility: visible;
    transition: top .25s ease, opacity .25s ease;
  }

  #user-menu .link-button {
    /*border: 2px solid #111521;*/
    border: 2px solid #fa7e92;
    height: 45px;
    display: flex;
    flex-direction: row;
    align-items: center;
    padding-left: 20px;
    margin-bottom: 5px;
    background: none;
    transition: background .25s ease;
  }

  #user-menu .link-button:hover {
    /*background: #111521;*/
    background: #fa7e92;
  }

  #user-menu .fa {
    color: #fa7e92;
    font-size: 15px;
    margin-top: 2px;
    margin-right: 8px;
    transition: color .25s ease;
  }

  #user-menu .text {
    color: #fa7e92;
    font-family: "Montserrat", sans-serif;
    font-size: 15px;
    width: 100%;
    text-align: left;
    transition: color .25s ease;
  }

  #user-menu .link-button:hover .fa {
    /*color: #111521;*/
    color: white;
  }

  #user-menu .link-button:hover .text {
    /*color: #111521;*/
    color: white;
  }

</style>
