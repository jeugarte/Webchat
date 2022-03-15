<template>
 <router-view/>
</template>

<script>

export default {
  name: "App",
  methods: {
    onResize: function() {
      this.$store.commit("setWindowHeight");
    }
  },
  mounted() {
    window.addEventListener("resize", this.onResize);
    this.onResize();
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

</style>
