import React, { useState, useEffect } from "react";
import { get as axiosGet, post as axiosPost } from "axios";
import _ from "lodash";
import qs from "qs";
import { WidthProvider, Responsive } from "react-grid-layout";
const ResponsiveReactGridLayout = WidthProvider(Responsive);
import { Container, Row, Col, Button, Modal, Form } from "react-bootstrap";
import {
  PlusCircle as IconPlusCircle,
  Edit as IconEdit,
  X as IconX
} from "react-feather";
import "react-grid-layout/css/styles.css";
import "react-resizable/css/styles.css";

import EditItemModal from "./EditItemModal.jsx";

/**
 * This layout demonstrates how to use a grid with a dynamic number of elements.
 */
class AddRemoveLayout extends React.PureComponent {
  static defaultProps = {
    autoSize: true,
    rowHeight: 100,
    margin: [10, 10],
    containerPadding: [10, 10],
    compactType: "vertical",
    className: "layout bg-light",
    breakpoints: { xl: 1200, lg: 992, md: 768, sm: 576, xs: 0 },
    cols: { xl: 12, lg: 12, md: 10, sm: 6, xs: 4 }
  };

  constructor(props) {
    super(props);

    let items = _.map(props.pageInfo.components, (comp, i) => {
      let propValues = {};
      _.each(comp.property_values, curProp => {
        propValues[curProp.property_id] = curProp.value;
      });

      let urlList = comp.urls;

      return {
        i: "" + i,
        x: parseInt(comp.x_cord),
        y: parseInt(comp.y_cord),
        w: parseInt(comp.width),
        h: parseInt(comp.height),
        compId: comp.component_id,
        compName: comp.component_name,
        cssClasses: comp.css_classes,
        cssStyle: comp.css_style,
        propValues: propValues,
        urlList: urlList
      };
    });

    this.state = {
      pageInfo: props.pageInfo,
      items: items,
      newCounter: items.length,
      showAssignCompModal: false
    };

    this.onSaveLayout = this.onSaveLayout.bind(this);
    this.onAddItem = this.onAddItem.bind(this);
    this.onLayoutChange = this.onLayoutChange.bind(this);
    this.onBreakpointChange = this.onBreakpointChange.bind(this);
    this.onEditItem = this.onEditItem.bind(this);
    this.onEditItemSave = this.onEditItemSave.bind(this);
    this.getLayout = this.getLayout.bind(this);
    this.initGlobalFuncs = this.initGlobalFuncs.bind(this);
    this.getGridConfig = this.getGridConfig.bind(this);

    this.saveBtnRef = el => (this.saveBtn = el);
    this.saveInfoRef = el => (this.saveInfo = el);
  }

  initGlobalFuncs = () => {
    window.addGridLayoutItem = this.onAddItem;
    window.saveGridLayout = this.onSaveLayout;
    window.saveGridItem = this.onEditItemSave;
    if (window.parent.resizeIframe) {
      window.parent.resizeIframe();
    }
  };

  componentDidMount() {
    this.initGlobalFuncs();
  }

  componentDidUpdate() {
    this.initGlobalFuncs();
  }

  onSaveLayout = () => {
    this.saveBtn.disabled = true;

    let showLoader = window.parent.showLoader || (() => {});
    let hideLoader = window.parent.hideLoader || (() => {});
    let onSaveLayoutSuccess = window.parent.onSaveLayoutSuccess || (() => {});
    let onSaveLayoutFail = window.parent.onSaveLayoutFail || (() => {});

    const onErr = () => {
      this.saveInfo.classList.add("text-danger");
      this.saveInfo.innerHTML = "Error in contacting server";
    };

    let url = "../pagesAjax.jsp";
    // url = "/page.json"; //debug
    showLoader();
    axiosPost(
      url,
      qs.stringify({
        requestType: "savePageLayout",
        pageId: this.state.pageInfo.id,
        items: JSON.stringify(this.state.items)
      })
    )
      .then(r => {
        let resp = r.data;
        if (resp.status === 1) {
          this.saveInfo.classList.add("text-success");
          this.saveInfo.innerHTML = "Layout saved";
          onSaveLayoutSuccess("Layout saved");
        } else {
          onErr();
          onSaveLayoutFail(resp.message);
        }
      })
      .catch(err => {
        onErr();
        onSaveLayoutFail("Error in contacting server");
      })
      .finally(() => {
        this.saveBtn.disabled = false;
        hideLoader();
      });
  };

  onEditItem = (item, event) => {
    if (window.parent.editGridItem) {
      window.parent.editGridItem(item);
    }
    // this.setState({
    //   showAssignCompModal: true,
    //   editItem: item
    // });
  };
  onEditItemSave = itemData => {
    this.state.items.map(item => {
      if (item.i == itemData.itemId) {
        item.compId = itemData.compId;
        item.compName = itemData.compName;
        item.cssClasses = itemData.cssClasses;
        item.cssStyle = itemData.cssStyle;
        item.urlList = itemData.urlList;

        if (item.compId.length > 0) {
          item.propValues = itemData.propValues;
        } else {
          item.propValues = {};
        }
      }
    });

    // onEditItemSave = values => {
    //   let editItemId = this.state.editItem.i;
    //   this.state.items.map(item => {
    //     if (item.i === editItemId) {
    //       item.compId = values.compId;
    //       item.compName = values.compName;
    //       item.cssClasses = values.cssClasses;
    //       item.cssStyle = values.cssStyle;
    //       if (item.compId.length > 0) {
    //         item.propValues = values.propValues;
    //       } else {
    //         item.propValues = {};
    //       }
    //     }
    //   });
    this.setState({
      items: this.state.items,
      showAssignCompModal: false
    });
  };

  getLayout = () => {
    let layout = _.map(this.state.items, item => {
      return {
        i: item.i,
        x: item.x,
        y: item.y,
        w: item.w,
        h: item.h
      };
    });
    layout = [
      {
        i: "0",
        x: 1,
        y: 1,
        w: 4,
        h: 2
      }
    ];
    return layout;
  };

  createElement = item => {
    const removeStyle = {
      position: "absolute",
      right: "2px",
      top: "2px",
      cursor: "pointer",
      color: "black"
    };
    const editStyle = {
      position: "absolute",
      left: "2px",
      top: "2px",
      color: "black"
    };

    const compName = item.compId !== "" ? item.compName : "None";
    return (
      <div
        key={item.i}
        // data-grid={item}
        className="bg-info grid-item"
      >
        <Button
          variant="link"
          style={editStyle}
          onClick={e => this.onEditItem(item, e)}
        >
          <IconEdit size={16}></IconEdit>
        </Button>
        <Button
          variant="link"
          style={removeStyle}
          onClick={this.onRemoveItem.bind(this, item.i)}
        >
          <IconX size={16}></IconX>
        </Button>

        {
          <div
            className="text d-flex align-items-center justify-content-center"
            style={{ height: "100%" }}
          >
            <div className="">
              Component : {compName}
              <br />
              <span className="small">
                {window.debugGrid && JSON.stringify(item)}
              </span>
            </div>
          </div>
        }
      </div>
    );
  };

  onAddItem(compId) {
    let newItem = {
      i: this.state.newCounter.toString(),
      x: 0,
      y: Infinity, // puts it at the bottom
      w: 2,
      h: 2,
      compId: compId,
      compName: "",
      propValues: {},
      cssClasses: "",
      cssStyle: "",
      urlList: []
    };

    let items = this.state.items.concat(newItem);
    this.onEditItem(newItem);
    this.setState({
      // Add a new item. It must have a unique key!
      items: items,
      // Increment the counter to ensure key is always unique.
      newCounter: this.state.newCounter + 1
      //open edit for this item
      // showAssignCompModal: true,
      // editItem: newItem
    });
  }

  // We're using the cols coming back from this to calculate where to add new items.
  onBreakpointChange(breakpoint, cols) {
    this.setState({
      breakpoint: breakpoint,
      cols: cols
    });
  }

  onLayoutChange(layout) {
    let items = this.state.items.map(item => {
      _.each(layout, l => {
        if (l.i === item.i) {
          item.x = l.x;
          item.y = l.y;
          item.w = l.w;
          item.h = l.h;
        }
      });
      return item;
    });
    this.setState({ items: items });
    // this.props.onLayoutChange(layout);
    // this.setState({ layout: layout });
  }

  onRemoveItem(i) {
    this.setState({ items: _.reject(this.state.items, { i: i }) });
  }

  getGridConfig() {
    let gridConfig = _.extend({}, this.props);
    if (this.state.pageInfo.row_height) {
      let pi = this.state.pageInfo;
      if (_.isNumber(_.toNumber(pi.row_height))) {
        gridConfig.rowHeight = _.toNumber(pi.row_height);
      }
      if (
        _.isNumber(_.toNumber(pi.item_margin_x)) &&
        _.isNumber(_.toNumber(pi.item_margin_y))
      ) {
        gridConfig.margin = [
          _.toNumber(pi.item_margin_x),
          _.toNumber(pi.item_margin_y)
        ];
      }

      //not setting padding as this is preview
      //effect of item inner cannot be seen
      //instead the edit/delete/resize button positions are affected
      // if (
      //   _.isNumber(_.toNumber(pi.container_padding_x)) &&
      //   _.isNumber(_.toNumber(pi.container_padding_y))
      // ) {
      //   gridConfig.containerPadding = [
      //     _.toNumber(pi.container_padding_x),
      //     _.toNumber(pi.container_padding_y)
      //   ];
      // }
    }

    return gridConfig;
  }

  render() {
    window.debugGrid && console.log(this.state.items); //debug
    let layouts = {};
    _.each(this.props.breakpoints, (_value, key) => {
      layouts[key] = this.state.items;
    });
    return (
      <div className="w-100">
        <div className="row grid-designer-btn-row">
          <div className="col">
            <Button onClick={this.onAddItem}>
              Add Item <IconPlusCircle size="16" />
            </Button>
            <Button
              ref={this.saveBtnRef}
              variant="success"
              onClick={this.onSaveLayout}
              className="ml-2"
            >
              Save
            </Button>
            <span ref={this.saveInfoRef} className="small p-1 ml-1"></span>
          </div>
        </div>
        <div className="row">
          <div className="col p-0 bg-light" style={{ minHeight: "500px" }}>
            <ResponsiveReactGridLayout
              onLayoutChange={this.onLayoutChange}
              onBreakpointChange={this.onBreakpointChange}
              layouts={layouts}
              {...this.getGridConfig()}
            >
              {_.map(this.state.items, el => this.createElement(el))}
            </ResponsiveReactGridLayout>
          </div>
        </div>
        {this.state.showAssignCompModal && (
          <EditItemModal
            editItem={this.state.editItem || ""}
            show={this.state.showAssignCompModal}
            handleEditClose={() =>
              this.setState({ showAssignCompModal: false })
            }
            handleEditSave={this.onEditItemSave}
          ></EditItemModal>
        )}
      </div>
    );
  }
}
export default AddRemoveLayout;
