import React, { Component } from "react";
import ReactDOM from "react-dom";

class FormContainer extends Component {
  constructor() {
    super();

    this.state = {
      title: ""
    };
  }

  render() {
    return (
      <form id="article-form">
        <h3>Form Container</h3>
      </form>
    );
  }
}

export default FormContainer;
const wrapper = document.getElementById("form-container");
wrapper ? ReactDOM.render(<FormContainer />, wrapper) : false;
