import React, { Component } from "react";
import ReactDOM from "react-dom";
import GridDesigner from "./GridDesigner.jsx";
import "bootstrap/dist/css/bootstrap.min.css";
import "../../css/grid-designer.css";

class Main extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
    //this.onSubmit = this.onSubmit.bind(this);
  }

  onSubmit(event) {
    event.preventDefault();
  }

  render() {
    return (
      <div className="container-fluid ">
        <div className="row grid-designer-title-row">
          <div className="col h2">Grid Designer</div>
        </div>
        <div className="row">
          <div className="col">
            <GridDesigner></GridDesigner>
          </div>
        </div>
      </div>
    );
  }
}

export default Main;
const wrapper = document.getElementById("root");
wrapper ? ReactDOM.render(<Main />, wrapper) : false;
