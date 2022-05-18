<template>
 <router-view/>

  <!-- Display confirmation messages -->
  <div class = "confirmation" v-for = "confirmation in $store.getters.Confirmations" v-bind:key = "confirmation.id">
    <div>
      <p>{{ confirmation.message }}</p>
    </div>
  </div>

  <!-- Display processing screen -->
  <div id = "processing" v-if = "$store.getters.Processing">
    <h3>Processing</h3>
    <i class = "fa fa-spinner"></i>
  </div>
</template>

<script>

export default {
  name: "App",
  methods: {
    onResize: function() {
      this.$store.commit("setWindowHeight");
      this.$store.commit("setWindowWidth");
    }
  },
  mounted() {
    console.log(location.host);
    window.addEventListener("resize", this.onResize);
    this.onResize();

    // Clears processing screen when app is loaded/reloaded
    this.$store.commit('setProcessing', false);
  },
  created() {
    this.$store.commit("logOut");
    this.$store.dispatch("create");
  }
}

</script>


<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  margin: 0;
  padding: 0;
}

/* General link styling */
.link {
  position: relative;
  color: #fa7e92;
  text-decoration: none;
  transition: color .3s ease;
}

.link:hover {
  color: pink;
}

.link::after {
  content: "";
  width: 0;
  height: 1px;
  position: absolute;
  bottom: -5px;
  left: 50%;
  background: pink;
  transition: left .3s ease, width .3s ease;
}

.link:hover::after {
  width: 80%;
  left: 10%;
}

/* Confirmation popup styling */
.confirmation {
  position: fixed;
  z-index: 100000;
  left: 0;
  top: 0;
  width: 100%;
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
}

.confirmation > div {
  margin-top: 20px;
  background: black;
  border-radius: 13px;
  color: white;
  font-family: "Antic", sans-serif;
  font-size: 15px;
  box-sizing: border-box;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  padding: 10px 15px;
  box-shadow: 0 0 8px 0.5px rgba(17, 21, 33, 0.1);
}

/* Processing popup styling */
#processing {
  position: fixed;
  z-index: 100000;
  background: rgba(0, 0, 0, 0.3);
  width: 100%;
  height: 100%;
  left: 0;
  top: 0;
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  color: white;
  font-family: "Antic", sans-serif;
  font-size: 50px;
}

#processing .fa {
  margin-left: 25px;
  animation: rotation 2s infinite linear;
}

/* Processing popup animation */
@keyframes rotation {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(359deg);
  }
}


</style>
