<template>
  <div class = "container" v-on:keyup.enter = "postRegister"  v-bind:style = "{height: $store.getters.WindowHeight + 'px'}">
    <div class = "content">
      <h2>Register</h2>
        <div class = "form">
          <form>
            <div>
              <label for = "email">Email:</label>
              <input type = "text" name = "email" id = "email" v-model="form.email">
            </div>
            <div>
              <label for = "username">Username:</label>
              <input type = "text" name = "username" id = "username" v-model="form.username">
            </div>
            <div>
              <label for = "password">Password:</label>
              <input type = "password" name = "password" id = "password" v-model="form.password">
            </div>
            <div id = "pass-confirm-div">
              <label for = "pass-confirm">Confirm Password:</label>
              <input type = "password" name = "pass-confirm" id = "pass-confirm" v-model="passConfirm">
            </div>
          </form>
          <button type = "submit" v-on:click = "postRegister"> Submit</button>
        </div>
    </div>
    <div class = "login">
      <h6>Already have an account? <router-link to = "/login" class = "link">Log in here</router-link>.</h6>
    </div>
  </div>
</template>

<script>
export default {
  name: "Register",
  data () {
    return {
      form: {
        email: "",
        username: "",
        password: ""
      },
      passConfirm: ""
    }
  },
  methods: {
    postRegister: async function() {
      if (this.form.email === "" || !/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(this.form.email)) {
        window.alert("Please enter a valid email");
      } else if (this.form.username === "") {
        window.alert("Please enter a username");
      } else if (this.form.password !== this.passConfirm) {
        window.alert("Please make sure your password matches your confirmation password");
      } else {
        try {
          await this.$store.dispatch("RegisterUser", this.form);
          await this.$store.dispatch("AddContact", "bob");
          await this.$router.push("/");
        } catch (error) {
          window.alert(error);
        }
      }
    },
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

.login {
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

.login h6 {
  font-weight: 600;
  font-family: "Montserrat", sans-serif;
  font-size: 13px;
}

</style>