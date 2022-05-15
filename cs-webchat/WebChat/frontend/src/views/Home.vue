<template>
  <User />
  <Main />
</template>

<script>
import Main from '../components/Main.vue'
import User from '../components/User.vue'

export default {
  name: 'Home',
  components: {
    Main,
    User
  }
}
</script>
