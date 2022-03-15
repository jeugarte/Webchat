<template>
  <div class = "container" v-bind:style = "{height: $store.getters.WindowHeight + 'px'}">
    <div class = "content">
      <h2>Login</h2>
      <div class = "form">
        <div>
          <label for = "email">Email/Username:</label>
          <input type = "text" name = "email" id = "email" v-model="form.user">
        </div>
        <div>
          <label for = "password">Password:</label>
          <input type = "password" name = "password" id = "password" v-model="form.password">
        </div>
        <button type = "submit"> Submit</button>
      </div>
    </div>
    <div class = "register">
      <h6>Don't have an account? <router-link to = "/register" class = "link">Register here</router-link>.</h6>
    </div>
  </div>
</template>

<script>
export default {
  name: "Register",
  data () {
    return {
      form: {
        user: "",
        password: ""
      }
    }
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

.content {
  max-width: 450px;
  width: 95%;
  box-sizing: border-box;
  border: 1px solid #cccccc;
  border-radius: 16px;
  padding: 30px 50px;
  background: white;
  position: relative;
  top: 0;
  box-shadow: 0 0 10px 4px rgba(17, 21, 33, 0.3);
}

.content h2 {
  font-family: "Antic", sans-serif;
  font-size: 35px;
}

.content .form div {
  margin: 20px 0;
  width: 100%;
  font-size: 15px;
  color: rgba(64, 64, 64, 0.81);
  font-family: "Nunito", sans-serif;
  font-weight: lighter;
}

.content .form input {
  width: 95%;
  border-radius: 0;
  border: 1px solid #ddd;
  color: #333;
  background-color: transparent;
  outline: none;
  font-family: "Montserrat", sans-serif;
  padding: 8px 10px;
  height: 20px;
  margin-top: 5px;
}

.content .form input:focus {
  border: 1px solid #b9b9b9;
}

.content .form input[type = "checkbox"] {
  margin-right: 10px;
  width: 15px;
  border-radius: 0 !important;
  border: 1px solid #cccccc;
}

.content button {
  width: 100%;
  border: 1px #fa7e92 solid;
  color: #fa7e92;
  padding: 10px 0;
  font-family: "Nunito", sans-serif;
  cursor: pointer;
  background: none;
  transition: color .5s ease, background .5s ease;
  margin-bottom: 15px;
  margin-top: 10px;
}

.content button:hover {
  color: white;
  background: #fa7e92;
}

.register {
  max-width: 450px;
  width: 95%;
  box-sizing: border-box;
  border: 1px solid #cccccc;
  border-radius: 13px;
  padding: 20px 35px;
  background: white;
  position: relative;
  top: 10px;
  box-shadow: 0 0 10px 0.5px rgba(17, 21, 33, 0.3);
}

.register h6 {
  font-weight: 600;
  font-family: "Montserrat", sans-serif;
  font-size: 13px;
}


</style>