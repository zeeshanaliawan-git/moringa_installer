import React, { useState, useEffect } from "react";
import _ from "lodash";
import { Container, Row, Col, Button, Modal, Form } from "react-bootstrap";
import { get as axiosGet } from "axios";
/**
 * Edit Item modal for grid designer
 */
class EditItemModal extends React.PureComponent {
  //   static defaultProps = {
  //     autoSize: true,
  //   };

  constructor(props) {
    super(props);

    this.editItem = _.cloneDeep(this.props.editItem);
    this.propValues = this.editItem.propValues;

    this.state = {
      compId: this.editItem.compId,
      compList: null
    };

    this.handleSubmit = this.handleSubmit.bind(this);
    this.getCompOptions = this.getCompOptions.bind(this);
    this.onFieldChange = this.onFieldChange.bind(this);
  }

  componentDidMount() {
    if (this.state.compList === null) {
      let url = "../componentsAjax.jsp";
      //url = "/components.json";
      axiosGet(url, {
        params: {
          requestType: "getList",
          rand: "" + Math.random()
        }
      })
        .then(resp => {
          resp = resp.data;
          if (resp.status) {
            this.setState({ compList: resp.data.components });
          }
        })
        .catch(error => {})
        .finally(() => {});
    }
  }

  componentDidUpdate() {}

  handleSubmit = event => {
    event.preventDefault();
    event.stopPropagation();

    const form = event.currentTarget;
    const fields = form.elements;

    //debug
    // console.log(form.elements);
    // _.each(form.elements, ele => {
    //   console.log(ele.name + " = " + ele.value);
    // });

    if (form.checkValidity() === false) {
      form.classList.add("was-validated");
      return false;
    }

    let values = {
      compId: fields.compId.value,
      cssClasses: fields.cssClasses.value,
      cssStyle: fields.cssStyle.value,
      compName: "",
      propValues: {}
    };

    if (values.compId.length > 0) {
      _.each(this.state.compList, item => {
        if (values.compId === item.id) {
          values.compName = item.name;

          _.each(item.properties, curProp => {
            const propId = curProp.id;
            values.propValues[propId] = "";
            if (fields["prop_id_" + propId]) {
              const field = fields["prop_id_" + propId];
              let fieldValue = field.value;
              if (field.type == "checkbox") {
                fieldValue = field.checked ? "true" : "false";
              }
              values.propValues[propId] = fieldValue;
            }
          });
          return false;
        }
      });
    }

    this.props.handleEditSave(values);
  };

  getCompOptions = () => {
    if (this.state.compList !== null) {
      return (
        <>
          <option value="">--</option>
          {_.map(this.state.compList, (item, i) => {
            return (
              <option key={item.id} value={item.id}>
                {item.name}
              </option>
            );
          })}
        </>
      );
    } else {
      return <option value=""> Loading list ...</option>;
    }
  };

  onFieldChange = event => {
    let target = event.target;
    let name = target.name;
    let value = target.value;
    if (target.type == "checkbox") {
      value = target.checked ? "true" : "false";
    }
    this.propValues[name] = value;
  };

  allowNumberOnly = event => {
    var val = event.target.value;
    val = val.replace(/[^\d.,]/g, "");
    //keep only one decimal point, remove extras
    if (val.indexOf(".") >= 0) {
      var valArr = val.split(".");
      val = valArr[0] + "." + valArr.splice(1).join("");
    }
    if (val.indexOf(",") >= 0) {
      var valArr = val.split(",");
      val = valArr[0] + "." + valArr.splice(1).join("");
    }
    event.target.value = val;
  };
  onJsonInput = event => {
    let target = event.target;
    let val = target.value;
    let isValid = false;
    try {
      JSON.parse(val);
      isValid = true;
    } catch (error) {}
    if (!isValid) {
      target.setCustomValidity("Invalid JSON.");
    } else {
      target.setCustomValidity("");
      // target.classList.remove("is-invalid");
      // target.classList.add("is-valid");
    }
  };

  render() {
    console.log("EditItem Render");
    return (
      <div>
        <Modal
          show={this.props.show}
          onHide={this.props.handleEditClose}
          id="assign-comp-modal"
        >
          <Form
            className="form-horizontal"
            noValidate
            onSubmit={this.handleSubmit}
          >
            <Modal.Header closeButton>
              <Modal.Title>Assign Component</Modal.Title>
            </Modal.Header>
            <Modal.Body>
              <Container fluid={true}>
                <Form.Group as={Row} controlId="cssClasses">
                  <Form.Label column>CSS classes</Form.Label>
                  <Col xs="8">
                    <Form.Control
                      {...{
                        as: "input",
                        type: "text",
                        name: "cssClasses",
                        defaultValue: this.editItem.cssClasses
                      }}
                    ></Form.Control>
                  </Col>
                </Form.Group>
                <Form.Group as={Row} controlId="cssStyle">
                  <Form.Label column>CSS Style</Form.Label>
                  <Col xs="8">
                    <textarea
                      {...{
                        className: "form-control",
                        name: "cssStyle",
                        defaultValue: this.editItem.cssStyle,
                        onInput: this.onJsonInput
                      }}
                    ></textarea>
                    <div className="invalid-feedback">Invalid JSON object</div>
                  </Col>
                </Form.Group>
                <Form.Group as={Row} controlId="assign-component-select">
                  <Form.Label column>Component</Form.Label>
                  <Col xs="8">
                    <Form.Control
                      name="compId"
                      as="select"
                      className="custom-select"
                      value={this.state.compId}
                      onChange={e => this.setState({ compId: e.target.value })}
                    >
                      {this.getCompOptions()}
                    </Form.Control>
                  </Col>
                </Form.Group>
                <ComponentProperties
                  compId={this.state.compId}
                  compList={this.state.compList}
                  propValues={this.propValues}
                  onFieldChange={this.onFieldChange}
                  onJsonInput={this.onJsonInput}
                  allowNumberOnly={this.allowNumberOnly}
                />
              </Container>
            </Modal.Body>
            <Modal.Footer>
              <Button variant="secondary" onClick={this.props.handleEditClose}>
                Close
              </Button>
              <Button type="submit" variant="primary">
                Save Changes
              </Button>
            </Modal.Footer>
          </Form>
        </Modal>
      </div>
    );
  }
}

function ComponentProperties({
  compId,
  compList,
  propValues,
  onFieldChange,
  onJsonInput,
  allowNumberOnly
}) {
  let propsList = [];

  if (compId !== "" && compList !== null) {
    _.each(compList, comp => {
      if (comp.id === compId) {
        propsList = comp.properties;
      }
    });
  }

  if (propsList.length <= 0) {
    return "";
  } else {
    let retHtml = <></>;
    for (let i = 0; i < propsList.length; i++) {
      let curProp = propsList[i];
      let propId = curProp.id;
      let pType = curProp.type;
      let curValue = "";
      if (typeof propValues[propId] !== "undefined") {
        curValue = propValues[propId];
      }
      if (pType === "string") {
        let fieldProps = {
          as: "input",
          type: "text",
          name: "prop_id_" + propId,
          defaultValue: curValue,
          onChange: onFieldChange
        };
        if (curProp.is_required == "1") {
          fieldProps.required = true;
        }
        retHtml = (
          <>
            {retHtml}
            <Form.Group as={Row} controlId={propId}>
              <Form.Label column>{curProp.name}</Form.Label>
              <Col xs="8">
                <Form.Control {...fieldProps}></Form.Control>
                {fieldProps.required && (
                  <div className="invalid-feedback">Cannot be empty.</div>
                )}
              </Col>
            </Form.Group>
          </>
        );
      } else if (pType === "number") {
        let fieldProps = {
          as: "input",
          type: "text",
          name: "prop_id_" + propId,
          defaultValue: curValue,
          onChange: onFieldChange,
          onInput: allowNumberOnly
        };
        if (curProp.is_required == "1") {
          fieldProps.required = true;
        }
        retHtml = (
          <>
            {retHtml}
            <Form.Group as={Row} controlId={curProp.name}>
              <Form.Label column>{curProp.name}</Form.Label>
              <Col xs="8">
                <Form.Control {...fieldProps}></Form.Control>
                {fieldProps.required && (
                  <div className="invalid-feedback">
                    Cannot be empty and must be a valid number.
                  </div>
                )}
              </Col>
            </Form.Group>
          </>
        );
      } else if (pType === "boolean") {
        let fieldProps = {
          type: "checkbox",
          className: "form-check-input",
          name: "prop_id_" + propId,
          onChange: onFieldChange
        };
        if (curValue == "true") {
          fieldProps["checked"] = "checked";
        }
        retHtml = (
          <>
            {retHtml}
            <Form.Group as={Row} controlId={curProp.name}>
              <Form.Label column></Form.Label>
              <Col xs="8">
                <div className="form-check">
                  <input {...fieldProps}></input>
                  <label className="form-check-label">{curProp.name}</label>
                </div>
              </Col>
            </Form.Group>
          </>
        );
      } else if (pType === "json") {
        let fieldProps = {
          className: "form-control",
          name: "prop_id_" + propId,
          defaultValue: curValue,
          onChange: onFieldChange,
          onInput: onJsonInput
        };
        if (curProp.is_required == "1") {
          fieldProps.required = true;
        }
        retHtml = (
          <>
            {retHtml}
            <Form.Group as={Row} controlId={curProp.name}>
              <Form.Label column>{curProp.name}</Form.Label>
              <Col xs="8">
                <textarea {...fieldProps} />
                <div className="invalid-feedback">
                  {fieldProps.required ? "Required " : "Invalid"}JSON object
                </div>
              </Col>
            </Form.Group>
          </>
        );
      }
    }

    return retHtml;
  }
}

export default EditItemModal;
